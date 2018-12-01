// DRAMASimulator © 2018 Constantino Tsarouhas

import Foundation

/// A parsed script that can be readily converted into machine words.
///
/// A program is usually created from an array of statements and a mapping of symbols to indices in that array.
struct Program {
	
	/// Creates an empty program.
	init() {
		self.wordSequences = []
	}
	
	/// Assembles a program with given statements and mapping from symbols to statement indices.
	///
	/// - Requires: Every statement index in `statementIndicesBySymbol` is a valid index in the `statements` array.
	///
	/// - Parameter statements: The program's statements.
	/// - Parameter statementIndicesBySymbol: A mapping from symbols to indices in the `statements` array.
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
		
		wordSequences = try zip(statements, statements.indices).map { statement, index in
			do {
				return try WordSequence(from: statement, addressesBySymbol: addressesBySymbol)
			} catch WordSequence.EncodingError.incorrectFormat {
				throw AssemblyError.incorrectFormat(statementIndex: index)
			} catch SymbolicAddress.Error.undefinedSymbol(let symbol) {
				throw AssemblyError.undefinedSymbol(symbol, statementIndex: index)
			}
		}
		
	}
	
	/// The words defined in the program as word sequences.
	var wordSequences: [WordSequence]
	enum WordSequence {
		
		/// Lowers given statement into a sequence of words.
		init(from statement: Statement, addressesBySymbol: [Script.Symbol : Int]) throws {
			
			func command(instruction: Instruction, initialiser: (Command.Type) throws -> Command?) throws -> Command {
				guard let command = try initialiser(instruction.commandType) else { throw EncodingError.incorrectFormat }
				return command
			}
			
			func addressSpecification(from symbolicAddress: SymbolicAddress, index: AddressSpecification.Index?) throws -> AddressSpecification {
				return AddressSpecification(base: AddressWord(wrapping: try symbolicAddress.effectiveAddress(addressesBySymbol: addressesBySymbol)), index: index)
			}
			
			switch statement {
				
				case .nullaryCommand(let instruction):
				self = .command(try command(instruction: instruction) { type in
					try (type as? NullaryCommand.Type)?.init(instruction: instruction)
				})
				
				case .registerCommand(let instruction, primaryRegister: let register, secondaryRegister: nil):
				self = .command(try command(instruction: instruction) { type in
					try (type as? UnaryRegisterCommand.Type)?.init(instruction: instruction, register: register)
				})
				
				case .registerCommand(let instruction, let primaryRegister, let secondaryRegister?):
				self = .command(try command(instruction: instruction) { type in
					try (type as? BinaryRegisterCommand.Type)?.init(instruction: instruction, primaryRegister: primaryRegister, secondaryRegister: secondaryRegister)
				})
				
				case .addressCommand(let instruction, let addressingMode, register: nil, let address, let index):
				self = .command(try command(instruction: instruction) { type in
					try (type as? AddressCommand.Type)?.init(instruction: instruction, addressingMode: addressingMode, address: addressSpecification(from: address, index: index))
				})
				
				case .addressCommand(let instruction, let addressingMode, let register?, let address, let index):
				self = .command(try command(instruction: instruction) { type in
					try (type as? RegisterAddressCommand.Type)?.init(instruction: instruction, addressingMode: addressingMode, register: register, address: addressSpecification(from: address, index: index))
				})
				
				case .conditionCommand(let instruction, let addressingMode, let condition, let address, let index):
				self = .command(try command(instruction: instruction) { type in
					try (type as? ConditionAddressCommand.Type)?.init(instruction: instruction, addressingMode: addressingMode, condition: condition, address: addressSpecification(from: address, index: index))
				})
				
				case .array(let words):
				self = .array(words)
				
				case .zeroArray(let length):
				self = .zeroArray(length: length)
				
				case .noop:
				self = .array([])
				
				case .error(let error):
				throw error
				
			}
		}
		
		/// A single word containing a single command.
		case command(Command)
		
		/// An array of one or more words.
		case array([Word])
		
		/// A zero-initialised array of some length.
		case zeroArray(length: Int)
		
		/// The machine words contained in `self`.
		var words: AnyCollection<Word> {
			switch self {
				case .command(let command):				return .init(CollectionOfOne(CommandWord(command).base))
				case .array(let words):					return .init(words)
				case .zeroArray(length: let length):	return .init(repeatElement(.zero, count: length))
			}
		}
		
		enum EncodingError : LocalizedError {
			
			/// The command does not have the correct format.
			case incorrectFormat
			
			// See protocol.
			var errorDescription: String? {
				switch self {
					case .incorrectFormat:	return "Bevel met onjuist formaat"
				}
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
	enum AssemblyError : LocalizedError, StatementError {
		
		/// The program does not fit in memory.
		case overflow
		
		/// A command does not have the correct format.
		///
		/// - Parameter statementIndex: The index of the statement whose command is erroneous.
		case incorrectFormat(statementIndex: Int)
		
		/// An undefined symbol is specified in a symbolic address.
		///
		/// - Parameter statementIndex: The index of the statement whose command contains an undefined symbol.
		case undefinedSymbol(Script.Symbol, statementIndex: Int)
		
		// See protocol.
		var errorDescription: String? {
			switch self {
				case .overflow:											return "Programma past niet in geheugen"
				case .incorrectFormat:									return "Bevel met onjuist formaat"
				case .undefinedSymbol(let symbol, statementIndex: _):	return "“\(symbol)” is niet gedefinieerd"
			}
		}
		
		// See protocol.
		var statementIndex: Int? {
			switch self {
				case .overflow:											return nil
				case .incorrectFormat(statementIndex: let index):		return index
				case .undefinedSymbol(_, statementIndex: let index):	return index
			}
		}
		
	}
	
}
