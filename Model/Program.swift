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
		
		/// An array of some length of zero-initialised words.
		case array(length: Int)
		
		/// The machine words contained in `self`.
		var words: AnyCollection<Word> {
			switch self {
				case .command(let command):			return .init(CollectionOfOne(CommandWord(command).base))
				case .literal(let word):			return .init(CollectionOfOne(word))
				case .array(length: let length):	return .init(repeatElement(.zero, count: length))
			}
		}
		
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
