// DRAMASimulator © 2018 Constantino Tsarouhas

import Foundation

/// A human-readable encoded command or directive.
enum Statement {
	
	/// A statement encoding a nullary command.
	case nullaryCommand(operation: String)
	
	/// A statement encoding a unary or binary register command.
	case registerCommand(operation: String, primaryRegister: Register, secondaryRegister: Register?)
	
	/// A statement encoding an address or register address command.
	///
	/// - Invariant: `addressTerms` is nonempty.
	case addressCommand(operation: String, addressingMode: String?, register: Register?, addressTerms: [AddressTerm], index: AddressSpecification.Index?)
	
	/// A statement encoding a condition command.
	///
	/// - Invariant: `addressTerms` is nonempty.
	case conditionCommand(operation: String, addressingMode: String?, condition: Condition, addressTerms: [AddressTerm], index: AddressSpecification.Index?)
	
	/// A term in a symbolic address specification.
	enum AddressTerm {
		case literal(Int)
		case symbol(String)
	}
	
	/// A literal word.
	case literal(Word)
	
	/// A zero-initialised array of some length.
	case array(length: Int)
	
	/// Parses given line and returns the statement encoded therein, or `nil` if the line is empty or only contains whitespace and comments.
	///
	/// - Requires: `line` does not contain newlines.
	///
	/// - Parameter line: A single line of assembly code.
	init?(from line: String) throws {
		
		let line = line.firstIndex(of: "|").map { line[..<$0] }?.trimmingCharacters(in: .whitespaces) ?? line.trimmingCharacters(in: .whitespaces)
		guard !line.isEmpty else { return nil }
		let range = NSRange(location: 0, length: (line as NSString).length)
		
		func string(in match: NSTextCheckingResult, at group: Int) -> String {
			return (line as NSString).substring(with: match.range(at: group))
		}
		
		func optionalString(in match: NSTextCheckingResult, at group: Int) -> String? {
			let range = match.range(at: group)
			guard range.location != NSNotFound else { return nil }
			return (line as NSString).substring(with: range)
		}
		
		func register(in match: NSTextCheckingResult, at group: Int) -> Register {
			return Register(rawValue: Int(string(in: match, at: group))!)!
		}
		
		func optionalRegister(in match: NSTextCheckingResult, at group: Int) -> Register? {
			guard let string = optionalString(in: match, at: group) else { return nil }
			return Register(rawValue: Int(string)!)!
		}
		
		func addressTerms(in match: NSTextCheckingResult, at group: Int) throws -> [AddressTerm] {
			return try string(in: match, at: group).split(separator: "+", omittingEmptySubsequences: false).map { term in
				let term = term.trimmingCharacters(in: .whitespaces)
				guard !term.isEmpty else { throw ParsingError.emptyAddressTerm }
				if let literal = Int(term) {
					return .literal(literal)
				} else {
					return .symbol(term)
				}
			}
		}
		
		if let match = Statement.nullaryCommandExpression.firstMatch(in: line, range: range) {
			self = .nullaryCommand(operation: string(in: match, at: 1))
		} else if let match = Statement.registerCommandExpression.firstMatch(in: line, range: range) {
			self = .registerCommand(
				operation:			string(in: match, at: 1),
				primaryRegister:	register(in: match, at: 2),
				secondaryRegister:	optionalRegister(in: match, at: 3)
			)
		} else if let match = Statement.addressCommandExpression.firstMatch(in: line, range: range) {
			self = .addressCommand(
				operation:		string(in: match, at: 1),
				addressingMode:	string(in: match, at: 2),
				register:		optionalRegister(in: match, at: 3),
				addressTerms:	[],	// TODO
				index:			nil	// TODO
			)
		} else if let match = Statement.conditionCommandExpression.firstMatch(in: line, range: range) {
			// TODO
		} else {
			throw ParsingError.illegalFormat
		}
		
	}
	
	enum ParsingError : Error {
		
		/// The statement has an illegal format.
		case illegalFormat
		
		/// An address term is empty.
		case emptyAddressTerm
		
		/// An address specified in a statement exceeds the range allowed by an address word.
		case unrepresentableAddress
		
	}
	
	/// A regular expression for matching nullary commands.
	///
	/// Groups: operation
	private static let nullaryCommandExpression = expression(operationPattern)
	
	/// A regular expression for matching register commands.
	///
	/// Groups: operation, primary register, secondary register (opt.)
	private static let registerCommandExpression = expression(operationPattern, reqSpace, registerPattern, argSeparator, "(?:\(registerPattern))")
	
	/// A regular expression for matching register commands.
	///
	/// Groups: operation, register (opt.), base address specification, pre-index modifier (opt.), index register (opt.), post-index modifier (opt.)
	private static let addressCommandExpression = expression(operationPattern, reqSpace, "(?:\(registerPattern)\(argSeparator))", addressPattern)
	
	/// A regular expression for matching register commands.
	///
	/// Groups: operation, condition, base address specification, pre-index modifier (opt.), index register (opt.), post-index modifier (opt.)
	private static let conditionCommandExpression = expression(operationPattern, reqSpace, conditionPattern, argSeparator, addressPattern)
	
}

private func expression(_ subpatterns: String...) -> NSRegularExpression {
	return try! NSRegularExpression(pattern: "^\(subpatterns.joined())$", options: .caseInsensitive)
}

private let reqSpace = "\\s+"
private let optSpace = "\\s*"
private let argSeparator = "\(optSpace),\(optSpace)"

private let operationPattern = "([A-Z]{3})"
private let addressingModePattern = "\\.(w|a|d|i)"
private let registerPattern = "R([0-9])"
private let conditionPattern = "([A-Z]{2,4})"
private let addressPattern = "\(baseAddressPattern)(?:\(indexPattern))?"
private let baseAddressPattern = "[0-9a-z+\\s]+"
private let indexPattern = "\\(\(optIndexModifier)\(registerPattern)\(optIndexModifier)\\)"
private let optIndexModifier = "(\\+|\\-)?"
