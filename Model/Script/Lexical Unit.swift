// DRAMASimulator © 2018 Constantino Tsarouhas

import Foundation

/// A string encoding a statement, comment, or label.
///
/// A lexical unit is typically instantiated from string containing a single statement, label, or comment. The static method `units(in:)` automatically instantiates all lexical units contained in a source text.
enum LexicalUnit {
	
	/// A lexical unit having the form of a nullary command.
	case nullaryCommand(instruction: SourceRange, fullRange: SourceRange)
	
	/// A lexical unit having the form of a unary or binary register command.
	case registerCommand(instruction: SourceRange, primaryRegister: RegisterSourceRange, secondaryRegister: RegisterSourceRange?, fullRange: SourceRange)
	
	/// A lexical unit having the form of an address or register address command.
	case addressCommand(instruction: SourceRange, addressingMode: SourceRange?, register: RegisterSourceRange?, address: SourceRange, index: IndexSourceRange?, fullRange: SourceRange)
	
	/// A lexical unit having the form of a condition command.
	case conditionCommand(instruction: SourceRange, addressingMode: SourceRange?, condition: SourceRange, address: SourceRange, index: IndexSourceRange?, fullRange: SourceRange)
	
	/// A lexical unit having the form of an array of one or more words.
	case array(words: SourceRange, fullRange: SourceRange)
	
	/// A lexical unit having the form of an zero-initialised array of some length.
	case zeroArray(length: SourceRange, fullRange: SourceRange)
	
	/// A lexical unit having the form of a label.
	case label(symbol: SourceRange, fullRange: SourceRange)
	
	/// A lexical unit containing a comment.
	case comment(SourceRange)
	
	/// A lexical unit that could not be parsed.
	case error(ParsingError)
	
	struct RegisterSourceRange {
		
		fileprivate init?(in match: NSTextCheckingResult, from group: Int, source: String) {
			guard match.range(at: group).location != NSNotFound else { return nil }
			numberRange = SourceRange(match.range(at: group + 1), in: source)!
			fullRange = SourceRange(match.range(at: group), in: source)!
		}
		
		let numberRange: SourceRange
		let fullRange: SourceRange
		
	}
	
	struct IndexSourceRange {
		
		fileprivate init?(in match: NSTextCheckingResult, from group: Int, source: String) {
			
			let preindexationOperationRange = match.range(at: group)
			let indexRegisterRange = match.range(at: group + 1)
			let postindexationOperationRange = match.range(at: group + 2)
			guard indexRegisterRange.location != NSNotFound else { return nil }
			
			self.indexRegisterRange = SourceRange(indexRegisterRange, in: source)!
			self.preindexationOperationRange = preindexationOperationRange.location != NSNotFound ? SourceRange(preindexationOperationRange, in: source)! : nil
			self.postindexationOperationRange = postindexationOperationRange.location != NSNotFound ? SourceRange(postindexationOperationRange, in: source)! : nil
			
		}
		
		/// The source range of the index register.
		let indexRegisterRange: SourceRange
		
		/// The source range of the pre-indexation operation.
		let preindexationOperationRange: SourceRange?
		
		/// The source range of the post-indexation operation.
		let postindexationOperationRange: SourceRange?
		
	}
	
	/// Determines all lexical units in given source.
	static func units(in source: String) -> [LexicalUnit] {
		
		var units: [LexicalUnit] = []
		
		source.enumerateSubstrings(in: source.startIndex..<source.endIndex, options: [.byLines, .substringNotRequired]) { _, sRange, _, _ in
			
			let fRange = NSRange(sRange, in: source)
			func range(in match: NSTextCheckingResult, at group: Int) -> SourceRange {
				return SourceRange(match.range(at: group), in: source)!
			}
			
			let noncommentRange: SourceRange
			let commentRange: SourceRange?
			if let match = commentExpression.firstMatch(in: source, range: fRange) {
				noncommentRange = range(in: match, at: 1)
				commentRange = range(in: match, at: 2)
			} else {
				noncommentRange = sRange
				commentRange = nil
			}
			
			let symbolLabelRange: (SourceRange, SourceRange)?
			let statementRange: SourceRange
			if let match = labelExpression.firstMatch(in: source, range: .init(noncommentRange, in: source)) {
				symbolLabelRange = (range(in: match, at: 2), range(in: match, at: 1))
				statementRange = range(in: match, at: 3)
			} else {
				symbolLabelRange = nil
				statementRange = noncommentRange
			}
			
			if let (symbolRange, labelRange) = symbolLabelRange {
				units.append(.label(symbol: symbolRange, fullRange: labelRange))
			}
			
			if let unit = self.init(source: source, statementRange: statementRange) {
				units.append(unit)
			}
			
			if let range = commentRange {
				units.append(.comment(range))
			}
			
		}
		
		return units
		
	}
	
	/// Determines the statement lexical unit in given range in given source.
	///
	/// - Parameter source: The source text.
	/// - Parameter statementRange: The range in `source` that potentially contains the form of a single statement.
	///
	/// - Returns: `nil` if `source` is empty or only contains whitespace.
	private init?(source: String, statementRange: SourceRange) {
		
		guard
			let lowerBound = source.rangeOfCharacter(from: LexicalUnit.nonwhitespaceSet, range: statementRange)?.lowerBound,
			let upperBound = source.rangeOfCharacter(from: LexicalUnit.nonwhitespaceSet, options: .backwards, range: statementRange)?.lowerBound
		else { return nil }
		let trimmedRange = lowerBound...upperBound
		
		guard !source.isEmpty else { return nil }
		
		func range(in match: NSTextCheckingResult, at group: Int) -> SourceRange {
			return SourceRange(match.range(at: group), in: source)!
		}
		
		func optionalRange(in match: NSTextCheckingResult, at group: Int) -> SourceRange? {
			let range = match.range(at: group)
			guard range.location != NSNotFound else { return nil }
			return SourceRange(range, in: source)
		}
		
		if let match = LexicalUnit.nullaryCommandExpression.firstMatch(in: source, range: NSRange(trimmedRange, in: source)) {
			self = .nullaryCommand(instruction: range(in: match, at: 1), fullRange: Range(match.range, in: source)!)
		} else if let match = LexicalUnit.registerCommandExpression.firstMatch(in: source, range: NSRange(trimmedRange, in: source)) {
			self = .registerCommand(
				instruction:		range(in: match, at: 1),
				primaryRegister:	RegisterSourceRange(in: match, from: 2, source: source)!,
				secondaryRegister:	RegisterSourceRange(in: match, from: 4, source: source),
				fullRange: 			Range(match.range, in: source)!
			)
		} else if let match = LexicalUnit.addressCommandExpression.firstMatch(in: source, range: NSRange(trimmedRange, in: source)) {
			self = .addressCommand(
				instruction:	range(in: match, at: 1),
				addressingMode:	optionalRange(in: match, at: 2),
				register:		RegisterSourceRange(in: match, from: 3, source: source),
				address:		range(in: match, at: 5),
				index:			IndexSourceRange(in: match, from: 6, source: source),
				fullRange: 		Range(match.range, in: source)!
			)
		} else if let match = LexicalUnit.conditionCommandExpression.firstMatch(in: source, range: NSRange(trimmedRange, in: source)) {
			self = .conditionCommand(
				instruction:	range(in: match, at: 1),
				addressingMode:	optionalRange(in: match, at: 2),
				condition:		range(in: match, at: 3),
				address:		range(in: match, at: 4),
				index:			IndexSourceRange(in: match, from: 5, source: source),
				fullRange: 		Range(match.range, in: source)!
			)
		} else if let match = LexicalUnit.arrayExpression.firstMatch(in: source, range: NSRange(trimmedRange, in: source)) {
			self = .array(words: range(in: match, at: 1), fullRange: Range(match.range, in: source)!)
		} else if let match = LexicalUnit.zeroArrayExpression.firstMatch(in: source, range: NSRange(trimmedRange, in: source)) {
			self = .zeroArray(length: range(in: match, at: 1), fullRange: Range(match.range, in: source)!)
		} else {
			self = .error(ParsingError.illegalFormat(range: statementRange))
		}
		
	}
	
	/// A regular expression matching nullary commands.
	///
	/// Groups: operation
	private static let nullaryCommandExpression = expression(operationPattern)
	
	/// A regular expression matching unary and binary register commands.
	///
	/// Groups: operation, primary register, reg. #, secondary register (opt.), reg. # (opt.)
	private static let registerCommandExpression = expression(operationPattern, reqSpace, group(registerPattern), opt(argSeparator, group(registerPattern)))
	
	/// A regular expression matching address and register–address commands.
	///
	/// Groups: operation, addressing mode (opt.), register (opt.), reg. # (opt.), base address, pre-index modifier (opt.), index register (opt.), post-index modifier (opt.)
	private static let addressCommandExpression = expression(qualifiedOperationPattern, reqSpace, opt(group(registerPattern), argSeparator), addressPattern)
	
	/// A regular expression matching condition–address commands.
	///
	/// Groups: operation, addressing mode (opt.), condition, base address, pre-index modifier (opt.), index register (opt.), post-index modifier (opt.)
	private static let conditionCommandExpression = expression(qualifiedOperationPattern, reqSpace, conditionPattern, argSeparator, addressPattern)
	
	/// A regular expression matching zero-initialised arrays.
	///
	/// Groups: comma-separated literals
	private static let arrayExpression = expression(group(literalConstantPattern, "(?:", optSpace, ",", optSpace, literalConstantPattern, ")*"))
	
	/// A regular expression matching zero-initialised arrays.
	///
	/// Groups: array length
	private static let zeroArrayExpression = expression("RESGR", reqSpace, arrayLengthPattern)
	
	/// A regular expression matching comments.
	///
	/// Groups: non-comment, comment (incl. |)
	private static let commentExpression = expression(anchored: false, group("[^|]*"), group("\\|.*"))
	
	/// A regular expression matching labels.
	///
	/// Groups: full label, symbol, remainder
	private static let labelExpression = expression(anchored: false, group(group(symbolPattern), optSpace, ":"), group(".*"))
	
	/// A character set containing all characters except whitespaces.
	private static let nonwhitespaceSet = CharacterSet.whitespaces.inverted
	
	enum ParsingError : LocalizedError, SourceError {
		
		/// A statement has an illegal format.
		case illegalFormat(range: SourceRange)
		
		// See protocol.
		var errorDescription: String? {
			switch self {
				case .illegalFormat:	return "Lijn met ongeldig formaat"
			}
		}
		
		// See protocol.
		var sourceRange: SourceRange {
			switch self {
				case .illegalFormat(range: let range):	return range
			}
		}
		
	}
	
	/// The range of the whole lexical unit.
	var fullRange: SourceRange {
		switch self {
			case .nullaryCommand(instruction: _, fullRange: let range):																return range
			case .registerCommand(instruction: _, primaryRegister: _, secondaryRegister: _, fullRange: let range):					return range
			case .addressCommand(instruction: _, addressingMode: _, register: _, address: _, index: _, fullRange: let range):		return range
			case .conditionCommand(instruction: _, addressingMode: _, condition: _, address: _, index: _, fullRange: let range):	return range
			case .array(_, fullRange: let range):				return range
			case .zeroArray(length: _, fullRange: let range):	return range
			case .label(symbol: _, fullRange: let range):		return range
			case .comment(let range):							return range
			case .error(let error):								return error.sourceRange
		}
	}
	
}

typealias SourceRange = Range<String.Index>

private func expression(anchored: Bool = true, _ subpatterns: String...) -> NSRegularExpression {
	let pattern = subpatterns.joined()
	return try! NSRegularExpression(pattern: anchored ? "^\(pattern)$" : pattern, options: .caseInsensitive)
}

private func opt(_ subpatterns: String...) -> String {
	return "(?:\(subpatterns.joined()))?"
}

private func group(_ subpatterns: String...) -> String {
	return "(\(subpatterns.joined()))"
}

private let reqSpace = "\\s+"
private let optSpace = "\\s*"
private let argSeparator = "\(optSpace),\(optSpace)"

private let operationPattern = "([A-Z]{3})"
private let addressingModePattern = "\\.(w|a|d|i)"
private let qualifiedOperationPattern = "\(operationPattern)(?:\(addressingModePattern))?"

private let registerPattern = "R([0-9])"
private let conditionPattern = "([A-Z]{2,4})"

private let addressPattern = "(\(baseAddressPattern))(?:\(indexPattern))?"
private let baseAddressPattern = "\(addressTermPattern)(?:\(optSpace)\\+\(optSpace)\(addressTermPattern))*"
private let addressTermPattern = "(?:\(symbolPattern)|-?[0-9]+)"
private let indexPattern = "\\(\(optIndexModifier)\(registerPattern)\(optIndexModifier)\\)"
private let optIndexModifier = "(\\+|\\-)?"

private let literalConstantPattern = "-?[0-9]{1,10}"
private let arrayLengthPattern = "([0-9]{1,4})"
private let symbolPattern = "[a-z_][a-z0-9_]*"
