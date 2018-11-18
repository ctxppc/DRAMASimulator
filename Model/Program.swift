// DRAMASimulator © 2018 Constantino Tsarouhas

/// A parsed script that can be readily converted into machine words.
struct Program {
	
	/// The words defined in the program as word sequences.
	var wordSequences: [WordSequence]
	enum WordSequence {
		
		/// A single word containing a single command.
		case command(Command)
		
		/// A single word containing a single literal.
		case literal(Word)
		
		/// A range of some length of zero-initialised words.
		case range(length: Int)
		
		/// The machine words contained in `self`.
		var words: AnyCollection<Word> {
			switch self {
				case .command(let command):			return .init(CollectionOfOne(CommandWord(command).base))
				case .literal(let word):			return .init(CollectionOfOne(word))
				case .range(length: let length):	return .init(repeatElement(.zero, count: length))
			}
		}
		
	}
	
	/// The bounds of the program text section.
	let textSectionBounds = 0..<200
	
	/// The commands.
	///
	/// Non-native commands are translated into their native representation before assembly.
	var commands: [Command]
	
	/// The bounds of the program data section.
	let dataSectionBounds = 200..<800
	
	/// The offsets inside the data section keyed by symbol name.
	private(set) var dataOffsetsBySymbol: [String : AddressWord] = [:]
	
	/// The memory section where globals can be added.
	private(set) var dataSection: [Word] = []
	
	/// Adds given words to the data section, assigns them to given symbol, and returns the absolute address to the first element.
	mutating func addWords<Words : Collection>(_ words: Words, symbol: String) throws -> AddressWord where Words.Element == Word {
		
		guard !dataOffsetsBySymbol.keys.contains(symbol) else { throw SymbolError.duplicateSymbol }
		let address = AddressWord(rawValue: dataSection.endIndex + dataSectionBounds.lowerBound)!
		guard dataSectionBounds.contains(address.unsignedValue) else { throw AssemblyError.overflow }
		
		dataOffsetsBySymbol[symbol] = address
		dataSection.append(contentsOf: words)
		
		return address
		
	}
	
	/// Allocates a sequence of zero-initialised words of some size, assigns them to given symbol, and returns the absolute address to the first element.
	mutating func allocateWords(count: Int, symbol: String) throws -> AddressWord {
		return try addWords(repeatElement(.zero, count: count), symbol: symbol)
	}
	
	/// An error related to symbols.
	enum SymbolError : Error {
		
		/// The symbol is already associated with an offset.
		case duplicateSymbol
		
	}
	
	/// Assembles the program into machine words, ready to be loaded into and executed by a machine.
	///
	/// - Returns: An array encoding the program in exactly `AddressWord.unsignedUpperBound` words.
	func machineWords() throws -> [Word] {
		let words = wordSequences.flatMap { $0.words }
		guard words.count <= AddressWord.unsignedUpperBound else { throw AssemblyError.overflow }
		return words + repeatElement(.zero, count: AddressWord.unsignedUpperBound - words.count)
	}
	
	/// An error related to assembly such as memory management or command lowering.
	enum AssemblyError : Error {
		
		/// The program does not fit in memory.
		case overflow
		
	}
	
}
