// DRAMASimulator © 2018–2021 Constantino Tsarouhas

import DepthKit

/// A value representing a machine memory.
struct Memory : Equatable, RandomAccessCollection, MutableCollection {
	
	// See protocol.
	enum Index : Hashable, Comparable, Strideable {
		
		/// The value refers to a memory cell.
		case address(AddressWord)
		
		/// The value refers to position after the last memory cell.
		case end
		
		/// The address referenced by the index, or `nil` if `self` is `.end`.
		var address: AddressWord? {
			switch self {
				case .address(let address):	return address
				case .end:					return nil
			}
		}
		
		// See protocol.
		func advanced(by distance: Int) -> Index {
			var copy = self
			copy.rawValue += distance
			return copy
		}
		
		// See protocol.
		func distance(to other: Index) -> Int {
			self.rawValue.distance(to: other.rawValue)
		}
		
		private var rawValue: Int {
			
			get {
				switch self {
					case .address(let address):	return address.rawValue
					case .end:					return AddressWord.unsignedRange.upperBound
				}
			}
			
			set {
				if let address = AddressWord(rawValue: newValue) {
					self = .address(address)
				} else if newValue == AddressWord.unsignedRange.upperBound {
					self = .end
				} else {
					preconditionFailure("Index out of bounds")
				}
			}
			
		}
		
	}
	
	// See protocol.
	var startIndex: Index { .address(.zero) }
	
	// See protocol.
	var endIndex: Index { .end }
	
	// See protocol.
	subscript (index: Index) -> MachineWord {
		
		get {
			guard case .address(let address) = index else { preconditionFailure("Index out of bounds") }
			return self[address]
		}
		
		set {
			guard case .address(let address) = index else { preconditionFailure("Index out of bounds") }
			self[address] = newValue
		}
		
	}
	
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
		Int(UInt(address.rawValue) & Self.internalAddressMask)
	}
	
	private func address(externalAddress: Int, internalAddress: Int) -> AddressWord {
		AddressWord(rawValue: (externalAddress << Self.internalAddressLength) + internalAddress) !! "External or internal address overflow"
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
	private static let internalAddressMask: UInt = ~(~0 << Self.internalAddressLength)
	
	/// The bins.
	private var bins = [Bin](repeating: .zero, count: numberOfBins)
	private enum Bin : Equatable, MutableCollection, RandomAccessCollection {
		
		/// A zero-filled bin.
		case zero
		
		/// A data bin.
		case data(buffer: [MachineWord])
		
		// See protocol.
		var startIndex: Int { 0 }
		
		// See protocol.
		var endIndex: Int { Memory.numberOfWordsPerBin }
		
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
		
		/// Returns the index to the first non-zero word in the bin.
		func indexOfFirstNonzeroWord() -> Int? {
			switch self {
				case .zero:				return nil
				case .data(let buffer):	return buffer.firstIndex(where: { $0 != .zero })
			}
		}
		
		/// Returns the index to the last non-zero word in the bin.
		func indexOfLastNonzeroWord() -> Int? {
			switch self {
				case .zero:				return nil
				case .data(let buffer):	return buffer.lastIndex(where: { $0 != .zero })
			}
		}
		
	}
	
	/// The range of indices of memory cells that form a contiguous zero-word space.
	var emptySpace: Range<Index> {
		
		let middleBin = bins.count / 2
		let lowerBins = bins.startIndex..<middleBin
		let upperBins = middleBin..<bins.endIndex
		
		let lowerBound: Index = {
			for externalAddress in lowerBins.reversed() {
				if let internalAddress = bins[externalAddress].indexOfLastNonzeroWord() {
					return .address(address(externalAddress: externalAddress, internalAddress: internalAddress))
				}
			}
			return startIndex
		}()
		
		let upperBound: Index = {
			for externalAddress in upperBins {
				if let internalAddress = bins[externalAddress].indexOfLastNonzeroWord() {
					return .address(address(externalAddress: externalAddress, internalAddress: internalAddress))
				}
			}
			return endIndex
		}()
		
		return lowerBound..<upperBound
		
	}
	
}
