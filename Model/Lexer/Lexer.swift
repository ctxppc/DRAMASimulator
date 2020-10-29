// DRAMASimulator © 2020 Constantino Tsarouhas

import DepthKit
import Foundation

/// A value that converts a source text into a sequence of lexical units.
struct Lexer {
	
	/// Creates a lexer for converting given string to lexical units.
	init(for sourceText: String) {
		self.sourceText = sourceText
		self.indexOfNextCharacter = sourceText.startIndex
		consumeWhitespace()
	}
	
	/// The source text.
	let sourceText: String
	
	/// An index to the next character in `sourceText` to be processed.
	private var indexOfNextCharacter: String.Index
	
	/// A Boolean value indicating whether the lexer has any source text that can be processed.
	var hasUnprocessedText: Bool {
		sourceText.indices.contains(indexOfNextCharacter)
	}
	
	/// Attempts to extract a lexical unit.
	mutating func extractUnit<Unit : LexicalUnit>(ofType type: Unit.Type = Unit.self) throws -> Unit? {
		
		guard hasUnprocessedText else { return nil }
		
		let searchRange = NSRange(indexOfNextCharacter..., in: sourceText)
		guard let match = Unit.pattern.firstMatch(in: sourceText, options: .anchored, range: searchRange) else { return nil }
		
		let captures = (0..<match.numberOfRanges).map {
			sourceText[SourceRange(match.range(at: $0), in: sourceText) !! "Expected valid substring range"]
		}
		let unitRange = SourceRange(match.range, in: sourceText) !! "Expected valid substring range"
		guard let unit = Unit(captures: captures, sourceRange: unitRange) else { return nil }
		
		indexOfNextCharacter = unitRange.upperBound
		consumeWhitespace()
		
		return unit
		
	}
	
	/// Ignores any leading whitespace characters from the unprocessed source text.
	private mutating func consumeWhitespace() {
		indexOfNextCharacter = sourceText[indexOfNextCharacter...].firstIndex(where: { !$0.isWhitespace }) ?? sourceText.endIndex
	}
	
}
