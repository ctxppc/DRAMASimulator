// DRAMASimulator © 2020 Constantino Tsarouhas

import DepthKit
import Foundation

/// A value that produces lexemes from a source text.
///
/// The lexer ignores horizontal whitespace such as spaces or tabs but does not ignore line terminators such as newlines.
struct Lexer {
	
	/// The known lexeme types, in pattern matching order.
	private static let lexemeTypes: [Lexeme.Type] = [
		RegisterLexeme.self,
		ConditionLexeme.self,
		LiteralLexeme.self,
		PreprocessorLabelLexeme.self,
		PreprocessorVariableAccessLexeme.self,
		ProgramTerminatorLexeme.self,
		AddressingModeLexeme.self,
		ArgumentSeparatorLexeme.self,
		StatementTerminatorLexeme.self,
		LabelMarkerLexeme.self,
		ArithmeticOperatorLexeme.self,
		IndexRegisterScopeLexeme.self,
		CommentLexeme.self,
		IdentifierLexeme.self,	// keep after other alphanumeric patterns!
		UnrecognisedLexeme.self	// always keep last!
	]
	
	/// Decomposes given source text to its lexemes.
	init(from sourceText: String) {
		
		self.sourceText = sourceText
		self.indexOfNextCharacter = sourceText.startIndex
		self.lexemes = []
		
		consumeHorizontalWhitespace()
		while hasUnprocessedText {
			lexemes.append(extractUnit())
		}
		
	}
	
	/// The source text.
	let sourceText: String
	
	/// The lexemes in the source.
	private(set) var lexemes: [Lexeme]
	
	/// An index to the next character in `sourceText` to be processed.
	private var indexOfNextCharacter: String.Index
	
	/// A Boolean value indicating whether the lexer has any source text that can be processed.
	private var hasUnprocessedText: Bool {
		sourceText.indices.contains(indexOfNextCharacter)
	}
	
	/// Extracts a lexeme of some known type from the unprocessed source.
	///
	/// - Requires: `hasUnprocessedText`.
	private mutating func extractUnit() -> Lexeme {
		
		for type in Self.lexemeTypes {
			if let unit = extractUnit(ofType: type) {
				return unit
			}
		}
		
		preconditionFailure("Expected last lexeme type to be UnrecognisedLexeme, or for that lexeme to match the unrecognised source.")
		
	}
	
	/// Extracts a lexeme of some given type from the unprocessed source.
	///
	/// - Requires: `hasUnprocessedText`.
	private mutating func extractUnit(ofType type: Lexeme.Type) -> Lexeme? {
		
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
