// DRAMASimulator © 2018 Constantino Tsarouhas

import Foundation

/// A human-readable encoded command or directive.
///
/// A statement is typically instantiated from a lexical unit. Every lexical unit maps to exactly one statement: comments and labels are translated to `noop` statements whereas errors are mapped to `error` statements.
enum Statement {
	
	/// A statement encoding a nullary command.
	case nullaryCommand(instruction: Instruction)
	
	/// A statement encoding a unary or binary register command.
	case registerCommand(instruction: Instruction, primaryRegister: Register, secondaryRegister: Register?)
	
	/// A statement encoding an address or register address command.
	case addressCommand(instruction: Instruction, addressingMode: AddressingMode?, register: Register?, address: SymbolicAddress, index: AddressSpecification.Index?)
	
	/// A statement encoding a condition command.
	case conditionCommand(instruction: Instruction, addressingMode: AddressingMode?, condition: Condition, address: SymbolicAddress, index: AddressSpecification.Index?)
	
	/// An array of one or more words.
	case array([Word])
	
	/// A zero-initialised array of some length.
	case zeroArray(length: Int)
	
	/// A statement that does nothing, e.g., for mapping labels or comments.
	///
	/// A no-operation statement is ignored during lowering into machine words.
	case noop
	
	/// A statement that could not be instantiated.
	case error(Error)
	
	/// Converts a given lexical unit into a statement.
	///
	/// - Parameter lexicalUnit: The lexical unit to convert into a statement.
	/// - Parameter source: The source from which the lexical units originate.
	init(from lexicalUnit: LexicalUnit, source: String) {
		
		func instruction(in range: SourceRange) throws -> Instruction {
			let mnemonic = source[range].uppercased()
			guard let instruction = Instruction(rawValue: mnemonic) else { throw ParsingError.unknownMnemonic(mnemonic) }
			return instruction
		}
		
		func register(in range: LexicalUnit.RegisterSourceRange) -> Register {
			return Register(rawValue: Int(source[range.numberRange])!)!
		}
		
		func addressingMode(in range: SourceRange) throws -> AddressingMode? {
			let code = source[range].lowercased()
			guard let mode = AddressingMode(rawValue: code) else { throw ParsingError.unknownAddressingMode(code) }
			return mode
		}
		
		func condition(in range: SourceRange) throws -> Condition {
			let rawValue = source[range].uppercased()
			guard let condition = Condition(rawValue: rawValue) ?? Condition(rawComparisonValue: rawValue) else { throw ParsingError.unknownCondition(rawValue) }
			return condition
		}
		
		func index(from range: LexicalUnit.IndexSourceRange) throws -> AddressSpecification.Index? {
			
			let modification: AddressSpecification.Index.Modification?
			switch (range.preindexationOperationRange.flatMap({ source[$0] }), range.postindexationOperationRange.flatMap({ source[$0] })) {
				case (nil, nil):	modification = nil
				case ("+", nil):	modification = .preincrement
				case ("-", nil):	modification = .predecrement
				case (nil, "+"):	modification = .postincrement
				case (nil, "-"):	modification = .postdecrement
				default:			throw ParsingError.doubleIndexModification
			}
			
			return .init(indexRegister: Register(rawValue: Int(source[range.indexRegisterRange])!)!, modification: modification)
			
		}
		
		do {
			switch lexicalUnit {
				
				case .nullaryCommand(instruction: let range, fullRange: _):
				self = try .nullaryCommand(instruction: instruction(in: range))
				
				case .registerCommand(instruction: let instructionRange, primaryRegister: let primaryRegister, secondaryRegister: let secondaryRegister, fullRange: _):
				self = try .registerCommand(
					instruction:		instruction(in: instructionRange),
					primaryRegister:	register(in: primaryRegister),
					secondaryRegister:	secondaryRegister.flatMap(register(in:))
				)
				
				case .addressCommand(instruction: let instructionRange, addressingMode: let addrMode, register: let registerRange, address: let address, index: let indexRange, fullRange: _):
				self = try .addressCommand(
					instruction:	instruction(in: instructionRange),
					addressingMode:	addrMode.flatMap(addressingMode(in:)),
					register:		registerRange.flatMap(register(in:)),
					address:		.init(from: source[address]),
					index:			indexRange.flatMap(index(from:))
				)
				
				case .conditionCommand(instruction: let instructionRange, addressingMode: let addrMode, condition: let conditionRange, address: let address, index: let indexRange, fullRange: _):
				self = try .conditionCommand(
					instruction:	instruction(in: instructionRange),
					addressingMode:	addrMode.flatMap(addressingMode(in:)),
					condition:		condition(in: conditionRange),
					address:		.init(from: source[address]),
					index:			indexRange.flatMap(index(from:))
				)
				
				case .array(let wordsRange, fullRange: _):
				self = .array(source[wordsRange].components(separatedBy: ",").map {
					Word(wrapping: Int($0.trimmingCharacters(in: .whitespaces))!)
				})
				
				case .zeroArray(length: let lengthRange, fullRange: _):
				self = .zeroArray(length: Int(source[lengthRange])!)
				
				case .label, .comment:
				self = .noop
				
				case .error(let error):
				throw error
				
			}
		} catch {
			self = .error(error)
		}
		
	}
	
	enum ParsingError : LocalizedError {
		
		/// A statement has an illegal format.
		case illegalFormat
		
		/// Both a pre- and post-indexation modification are specified.
		case doubleIndexModification
		
		/// An unknown mnemonic is specified.
		case unknownMnemonic(String)
		
		/// An unknown addressing mode is specified.
		case unknownAddressingMode(String)
		
		/// An unknown condition is specified.
		case unknownCondition(String)
		
		// See protocol.
		var errorDescription: String? {
			switch self {
				case .illegalFormat:					return "Bevel met ongeldig formaat"
				case .doubleIndexModification:			return "Dubbele indexatie"
				case .unknownMnemonic(let mnemonic):	return "Onbekend bevel “\(mnemonic)”"
				case .unknownAddressingMode(let mode):	return "Onbekende interpretatie “\(mode)”"
				case .unknownCondition(let condition):	return "Onbekende voorwaarde “\(condition)”"
			}
		}
		
	}
	
	/// The number of machine words used by the statement.
	var wordLength: Int {
		switch self {
			case .nullaryCommand:			return 1
			case .registerCommand:			return 1
			case .addressCommand:			return 1
			case .conditionCommand:			return 1
			case .array(let words):			return words.count
			case .zeroArray(let length):	return length
			case .noop:						return 0
			case .error:					return 0
		}
	}
	
}
