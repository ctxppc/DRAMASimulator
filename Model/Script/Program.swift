// DRAMASimulator © 2018 Constantino Tsarouhas

import Foundation

/// A parsed script that can be readily converted into machine words.
struct Program {
	
	/// Creates an empty program.
	init() {
		self.wordSequences = []
	}
	
	/// Assembles a program with given statements and mapping from symbols to statement indices.
	///
	/// - Throws: An error if an undefined symbol is referenced.
	init(statements: [Statement], statementIndicesBySymbol: [String : Int]) throws {
		
		var addressesByStatementIndex: [Int : Int] = [:]
		var nextAddress = 0
		for (statementIndex, statement) in statements.enumerated() {
			addressesByStatementIndex[statementIndex] = nextAddress
			nextAddress += statement.wordLength
		}
		
		var addressesBySymbol: [Script.Symbol : Int] = [:]
		for (symbol, statementIndex) in statementIndicesBySymbol {
			addressesBySymbol[symbol] = addressesByStatementIndex[statementIndex]
		}
		
		wordSequences = try statements.map {
			try WordSequence(from: $0, addressesBySymbol: addressesBySymbol)
		}
		
	}
	
	/// The words defined in the program as word sequences.
	var wordSequences: [WordSequence]
	enum WordSequence {
		
		init(from statement: Statement, addressesBySymbol: [Script.Symbol : Int]) throws {
			
			func command(instruction: Instruction, initialiser: (Command.Type) throws -> Command?) throws -> Command {
				guard let type = supportedCommandTypes.first(where: { $0.supportedInstructions.contains(instruction) }) else { preconditionFailure("Unimplemented mnemonic") }
				guard let command = try initialiser(type) else { throw AssemblyError.incorrectFormat }
				return command
			}
			
			func commandType<T>(for instruction: Instruction, ofType type: T.Type) throws -> T.Type {
				guard let type = supportedCommandTypes.first(where: { $0.supportedInstructions.contains(instruction) }) else { preconditionFailure("Unimplemented mnemonic") }
				guard let narrowedType = type as? T.Type else { throw AssemblyError.incorrectFormat }
				return narrowedType
			}
			
			func addressSpecification(from symbolicAddress: SymbolicAddress, index: AddressSpecification.Index?) throws -> AddressSpecification {
				return AddressSpecification(base: AddressWord(wrapping: try symbolicAddress.effectiveAddress(addressesBySymbol: addressesBySymbol)), index: index)
			}
			
			switch statement {
				
				case .nullaryCommand(let instruction, syntaxMap: _):
				self = .command(try command(instruction: instruction) { type in
					try (type as? NullaryCommand.Type)?.init(instruction: instruction)
				})
				
				case .registerCommand(let instruction, primaryRegister: let register, secondaryRegister: nil, syntaxMap: _):
				self = .command(try command(instruction: instruction) { type in
					try (type as? UnaryRegisterCommand.Type)?.init(instruction: instruction, register: register)
				})
				
				case .registerCommand(let instruction, let primaryRegister, let secondaryRegister?, syntaxMap: _):
				self = .command(try command(instruction: instruction) { type in
					try (type as? BinaryRegisterCommand.Type)?.init(instruction: instruction, primaryRegister: primaryRegister, secondaryRegister: secondaryRegister)
				})
				
				case .addressCommand(let instruction, let addressingMode, register: nil, let address, let index, syntaxMap: _):
				self = .command(try command(instruction: instruction) { type in
					try (type as? AddressCommand.Type)?.init(instruction: instruction, addressingMode: addressingMode, address: addressSpecification(from: address, index: index))
				})
				
				case .addressCommand(let instruction, let addressingMode, let register?, let address, let index, syntaxMap: _):
				self = .command(try command(instruction: instruction) { type in
					try (type as? RegisterAddressCommand.Type)?.init(instruction: instruction, addressingMode: addressingMode, register: register, address: addressSpecification(from: address, index: index))
				})
				
				case .conditionCommand(let instruction, let addressingMode, let condition, let address, let index, syntaxMap: _):
				self = .command(try command(instruction: instruction) { type in
					try (type as? ConditionAddressCommand.Type)?.init(instruction: instruction, addressingMode: addressingMode, condition: condition, address: addressSpecification(from: address, index: index))
				})
				
				case .literal(let word, syntaxMap: _):
				self = .literal(word)
				
				case .array(let length, syntaxMap: _):
				self = .array(length: length)
				
			}
		}
		
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
	enum AssemblyError : LocalizedError {
		
		/// The program does not fit in memory.
		case overflow
		
		/// A command does not have the correct format.
		case incorrectFormat
		
		// See protocol.
		var errorDescription: String? {
			switch self {
				case .overflow:			return "Programma past niet in geheugen"
				case .incorrectFormat:	return "Bevel met onjuist formaat"
			}
		}
		
	}
	
}
