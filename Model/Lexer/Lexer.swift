// DRAMASimulator © 2020 Constantino Tsarouhas

import DepthKit
import Foundation

/// A value that produces lexical units from a source text.
///
/// The lexer ignores horizontal whitespace such as spaces or tabs but does not ignore line terminators such as newlines.
struct Lexer {
	
	/// The known lexical unit types, in pattern matching order.
	private static let lexicalUnitTypes: [LexicalUnit.Type] = [
		RegisterLexicalUnit.self,
		ConditionLexicalUnit.self,
		LiteralLexicalUnit.self,
		IdentifierLexicalUnit.self,		// keep after other alphanumeric patterns!
		AddressingModeLexicalUnit.self,
		ArgumentSeparatorLexicalUnit.self,
		StatementTerminatorLexicalUnit.self,
		ProgramTerminatorLexicalUnit.self,
		LabelMarkerLexicalUnit.self,
		ArithmeticOperatorLexicalUnit.self,
		IndexRegisterScopeLexicalUnit.self,
		CommentLexicalUnit.self,
		UnrecognisedLexicalUnit.self	// always keep last!
	]
	
	/// Decomposes given source text to its lexical units.
	init(from sourceText: String) {
		
		self.sourceText = sourceText
		self.indexOfNextCharacter = sourceText.startIndex
		self.lexicalUnits = []
		
		consumeHorizontalWhitespace()
		while hasUnprocessedText {
			lexicalUnits.append(extractUnit())
		}
		
	}
	
	/// The source text.
	let sourceText: String
	
	/// The lexical units in the source.
	private(set) var lexicalUnits: [LexicalUnit]
	
	/// An index to the next character in `sourceText` to be processed.
	private var indexOfNextCharacter: String.Index
	
	/// A Boolean value indicating whether the lexer has any source text that can be processed.
	private var hasUnprocessedText: Bool {
		sourceText.indices.contains(indexOfNextCharacter)
	}
	
	/// Extracts a lexical unit of some known type from the unprocessed source.
	///
	/// - Requires: `hasUnprocessedText`.
	private mutating func extractUnit() -> LexicalUnit {
		
		for type in Self.lexicalUnitTypes {
			if let unit = extractUnit(ofType: type) {
				return unit
			}
		}
		
		preconditionFailure("Expected last lexical unit type to be UnrecognisedLexicalUnit, or for that type to match unrecognised unit")
		
	}
	
	/// Extracts a lexical unit of some given type from the unprocessed source.
	///
	/// - Requires: `hasUnprocessedText`.
	private mutating func extractUnit(ofType type: LexicalUnit.Type) -> LexicalUnit? {
		
		let searchRange = NSRange(indexOfNextCharacter..., in: sourceText)
		guard let match = type.pattern.firstMatch(in: sourceText, options: .anchored, range: searchRange) else { return nil }
		
		let captures = (0..<match.numberOfRanges).map {
			sourceText[SourceRange(match.range(at: $0), in: sourceText) !! "Expected valid substring range"]
		}
		let unitRange = SourceRange(match.range, in: sourceText) !! "Expected valid substring range"
		guard let unit = type.init(captures: captures, sourceRange: unitRange) else { return nil }
		
		indexOfNextCharacter = unitRange.upperBound
		consumeHorizontalWhitespace()
		
		return unit
		
	}
	
	/// Ignores any leading horizontal whitespace characters from the unprocessed source text.
	private mutating func consumeHorizontalWhitespace() {
		indexOfNextCharacter = sourceText[indexOfNextCharacter...].firstIndex(where: { $0.isNewline || !$0.isWhitespace }) ?? sourceText.endIndex
	}
	
}
