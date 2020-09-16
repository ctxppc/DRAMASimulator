// DRAMASimulator © 2020 Constantino Tsarouhas

/// A value representing a machine memory.
struct Memory : Equatable {
	
	/// Accesses the word at given address.
	subscript (address: AddressWord) -> MachineWord {
		get { bins[externalAddress(from: address)][internalAddress(from: address)] }
		set { bins[externalAddress(from: address)][internalAddress(from: address)] = newValue }
	}
	
	/// Returns the address to the bin containing the word at `address`.
	private func externalAddress(from address: AddressWord) -> Int {
		address.rawValue >> Self.internalAddressLength
	}
	
	/// Returns the address to the word at `address` in the appropriate bin.
	private func internalAddress(from address: AddressWord) -> Int {
		address.rawValue >> Self.internalAddressLength
	}
	
	/// Loads given buffer into the memory.
	///
	/// - Parameter words: The words to load.
	/// - Parameter startAddress: The address in `self` of the first word.
	mutating func load(_ words: [MachineWord], startingFrom startAddress: AddressWord) {
		let addresses = sequence(first: startAddress, next: { $0.incremented() })
		for (word, address) in zip(words, addresses) {
			self[address] = word
		}
	}
	
	/// The number of bits in an internal address.
	private static let internalAddressLength = 7	// 2^7 = 128 (≈ 100 ≈ √10000); less than a page (usually 4 or 16 kiB)
	
	/// The size of a bin.
	private static let numberOfWordsPerBin = 2 ** internalAddressLength
	
	/// The number of bins.
	private static let numberOfBins = (AddressWord.unsignedUpperBound / numberOfWordsPerBin) + 1
	
	/// The mask
	private static let internalAddressMask = ~0 << Self.internalAddressLength
	
	/// The bins.
	private var bins = [Bin](repeating: .zero, count: numberOfBins)
	private enum Bin : Equatable {
		
		/// A zero-filled bin.
		case zero
		
		/// A data bin.
		case data(buffer: [MachineWord])
		
		/// Accesses the word at given internal address.
		subscript (address: Int) -> MachineWord {
			
			get {
				switch self {
					case .zero:			return .zero
					case .data(let b):	return b[address]
				}
			}
			
			set {
				var buffer: [MachineWord] = {
					switch self {
						case .zero:			return .init(repeating: .zero, count: Memory.numberOfWordsPerBin)
						case .data(let b):	return b
					}
				}()
				buffer[address] = newValue
				self = .data(buffer: buffer)
			}
			
		}
		
	}
	
}
