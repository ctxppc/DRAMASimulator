// DRAMASimulator © 2018 Constantino Tsarouhas

import Foundation

/// A human-readable encoded command or directive.
enum Statement {
	
	/// A statement encoding a nullary command.
	case nullaryCommand(instruction: Instruction, syntaxMap: SyntaxMap)
	
	/// A statement encoding a unary or binary register command.
	case registerCommand(instruction: Instruction, primaryRegister: Register, secondaryRegister: Register?, syntaxMap: SyntaxMap)
	
	/// A statement encoding an address or register address command.
	case addressCommand(instruction: Instruction, addressingMode: AddressingMode?, register: Register?, address: SymbolicAddress, index: AddressSpecification.Index?, syntaxMap: SyntaxMap)
	
	/// A statement encoding a condition command.
	case conditionCommand(instruction: Instruction, addressingMode: AddressingMode?, condition: Condition, address: SymbolicAddress, index: AddressSpecification.Index?, syntaxMap: SyntaxMap)
	
	/// A literal word.
	case literal(Word, syntaxMap: SyntaxMap)
	
	/// A zero-initialised array of some length.
	case array(length: Int, syntaxMap: SyntaxMap)
	
	/// Parses given line and returns the statement encoded therein, or `nil` if the line is empty or only contains whitespace and comments.
	///
	/// - Requires: `line` does not contain newlines.
	///
	/// - Parameter line: A single line of assembly code.
	init?(from line: Substring) throws {
		
		typealias Match = NSTextCheckingResult
		
		let line = line.firstIndex(of: "|").map { line[..<$0] }?.trimmingCharacters(in: .whitespaces) ?? line.trimmingCharacters(in: .whitespaces)
		guard !line.isEmpty else { return nil }
		let range = NSRange(location: 0, length: (line as NSString).length)
		
		func string(in match: Match, at group: Int) -> String {
			guard let value = optionalString(in: match, at: group) else { preconditionFailure("Missing capture group") }
			return value
		}
		
		func optionalString(in match: Match, at group: Int) -> String? {
			let range = match.range(at: group)
			guard range.location != NSNotFound else { return nil }
			return (line as NSString).substring(with: range)
		}
		
		func instruction(in match: Match, at group: Int) throws -> Instruction {
			let mnemonic = string(in: match, at: group).uppercased()
			guard let instruction = Instruction(rawValue: mnemonic) else { throw ParsingError.unknownMnemonic(mnemonic) }
			return instruction
		}
		
		func optionalAddressingMode(in match: Match, at group: Int) throws -> AddressingMode? {
			guard let value = optionalString(in: match, at: group) else { return nil }
			guard let mode = AddressingMode(rawValue: value.lowercased()) else { throw ParsingError.unknownAddressingMode(value) }
			return mode
		}
		
		func register(in match: Match, at group: Int) -> Register {
			return Register(rawValue: Int(string(in: match, at: group))!)!
		}
		
		func optionalRegister(in match: Match, at group: Int) -> Register? {
			guard let string = optionalString(in: match, at: group) else { return nil }
			return Register(rawValue: Int(string)!)!
		}
		
		func index(in match: Match, from group: Int) throws -> AddressSpecification.Index? {
			
			guard let register = optionalRegister(in: match, at: group + 1) else { return nil }
			
			let modification: AddressSpecification.Index.Modification?
			switch (optionalString(in: match, at: group), optionalString(in: match, at: group + 2)) {
				case (nil, nil):	modification = nil
				case ("+", nil):	modification = .preincrement
				case ("-", nil):	modification = .predecrement
				case (nil, "+"):	modification = .postincrement
				case (nil, "-"):	modification = .postdecrement
				default:			throw ParsingError.doubleIndexModification
			}
			
			return .init(indexRegister: register, modification: modification)
			
		}
		
		func condition(in match: Match, at group: Int) throws -> Condition {
			let rawValue = string(in: match, at: group).uppercased()
			guard let condition = Condition(rawValue: rawValue) ?? Condition(rawComparisonValue: rawValue) else { throw ParsingError.unknownCondition }
			return condition
		}
		
		if let match = Statement.nullaryCommandExpression.firstMatch(in: line, range: range) {
			self = try .nullaryCommand(instruction: instruction(in: match, at: 1), syntaxMap: .init())	// TODO
		} else if let match = Statement.registerCommandExpression.firstMatch(in: line, range: range) {
			self = try .registerCommand(
				instruction:		instruction(in: match, at: 1),
				primaryRegister:	register(in: match, at: 2),
				secondaryRegister:	optionalRegister(in: match, at: 3),
				syntaxMap:			.init()	// TODO
			)
		} else if let match = Statement.addressCommandExpression.firstMatch(in: line, range: range) {
			self = try .addressCommand(
				instruction:	instruction(in: match, at: 1),
				addressingMode:	optionalAddressingMode(in: match, at: 2),
				register:		optionalRegister(in: match, at: 3),
				address:		.init(from: string(in: match, at: 4)),
				index:			index(in: match, from: 5),
				syntaxMap:		.init()	// TODO
			)
		} else if let match = Statement.conditionCommandExpression.firstMatch(in: line, range: range) {
			self = try .conditionCommand(
				instruction:	instruction(in: match, at: 1),
				addressingMode:	optionalAddressingMode(in: match, at: 2),
				condition:		condition(in: match, at: 3),
				address:		.init(from: string(in: match, at: 4)),
				index:			index(in: match, from: 5),
				syntaxMap:		.init()	// TODO
			)
		} else {
			throw ParsingError.illegalFormat
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
		case unknownCondition
		
		// See protocol.
		var errorDescription: String? {
			switch self {
				case .illegalFormat:					return "Bevel met ongeldig formaat"
				case .doubleIndexModification:			return "Dubbele indexatie"
				case .unknownMnemonic(let mnemonic):	return "Onbekend bevel ‘\(mnemonic)’"
				case .unknownAddressingMode(let mode):	return "Onbekende interpretatie ‘\(mode)’"
				case .unknownCondition:					return "Onbekende voorwaarde"
			}
		}
		
	}
	
	/// A regular expression for matching nullary commands.
	///
	/// Groups: operation
	private static let nullaryCommandExpression = expression(operationPattern)
	
	/// A regular expression for matching unary and binary register commands.
	///
	/// Groups: operation, primary register, secondary register (opt.)
	private static let registerCommandExpression = expression(operationPattern, reqSpace, registerPattern, argSeparator, opt(registerPattern))
	
	/// A regular expression for matching address and register–address commands.
	///
	/// Groups: operation, addressing mode (opt.), register (opt.), base address, pre-index modifier (opt.), index register (opt.), post-index modifier (opt.)
	private static let addressCommandExpression = expression(qualifiedOperationPattern, reqSpace, opt(registerPattern, argSeparator), addressPattern)
	
	/// A regular expression for matching condition–address commands.
	///
	/// Groups: operation, addressing mode (opt.), condition, base address, pre-index modifier (opt.), index register (opt.), post-index modifier (opt.)
	private static let conditionCommandExpression = expression(qualifiedOperationPattern, reqSpace, conditionPattern, argSeparator, addressPattern)
	
	/// The number of machine words used by the statement.
	var wordLength: Int {
		switch self {
			
			case .nullaryCommand, .registerCommand, .addressCommand, .conditionCommand, .literal:
			return 1
			
			case .array(let length, syntaxMap: _):
			return length
			
		}
	}
	
	/// The syntax map for the statement.
	var syntaxMap: SyntaxMap {
		switch self {
			case .nullaryCommand(instruction: _, syntaxMap: let map):															return map
			case .registerCommand(instruction: _, primaryRegister: _, secondaryRegister: _, syntaxMap: let map):				return map
			case .addressCommand(instruction: _, addressingMode: _, register: _, address: _, index: _, syntaxMap: let map):		return map
			case .conditionCommand(instruction: _, addressingMode: _, condition: _, address: _, index: _, syntaxMap: let map):	return map
			case .literal(_, syntaxMap: let map):																				return map
			case .array(length: _, syntaxMap: let map):																			return map
		}
	}
	
}

private func expression(_ subpatterns: String...) -> NSRegularExpression {
	return try! NSRegularExpression(pattern: "^\(subpatterns.joined())$", options: .caseInsensitive)
}

private let reqSpace = "\\s+"
private let optSpace = "\\s*"
private let argSeparator = "\(optSpace),\(optSpace)"

private func opt(_ expressions: String...) -> String {
	return "(?:\(expressions.joined()))?"
}

private let operationPattern = "([A-Z]{3})"
private let addressingModePattern = "\\.(w|a|d|i)"
private let qualifiedOperationPattern = "\(operationPattern)(?:\(addressingModePattern))?"
private let registerPattern = "R([0-9])"
private let conditionPattern = "([A-Z]{2,4})"
private let addressPattern = "(\(baseAddressPattern))(?:\(indexPattern))?"
private let baseAddressPattern = "[0-9a-z+\\s]+"
private let indexPattern = "\\(\(optIndexModifier)\(registerPattern)\(optIndexModifier)\\)"
private let optIndexModifier = "(\\+|\\-)?"
