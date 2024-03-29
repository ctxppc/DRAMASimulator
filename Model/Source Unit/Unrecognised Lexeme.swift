// DRAMASimulator © 2020 Constantino Tsarouhas

import Foundation

/// A lexeme representing a substring of source that cannot be mapped to a lexeme.
struct UnrecognisedLexeme : Lexeme {
	
	// See protocol.
	static let pattern = try! NSRegularExpression(pattern: #".+"#)
	
	// See protocol.
	init(captures: [Substring], sourceRange: SourceRange) {
		self.source = captures[0]
		self.sourceRange = sourceRange
	}
	
	/// The source that could not be mapped to a lexeme.
	let source: Substring
	
	// See protocol.
	var sourceRange: SourceRange
	
}
