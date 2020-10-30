// DRAMASimulator © 2020 Constantino Tsarouhas

import Foundation

/// A lexical unit representing a substring of source that cannot be mapped to a lexical unit.
struct UnrecognisedLexicalUnit : LexicalUnit {
	
	// See protocol.
	static let pattern = try! NSRegularExpression(pattern: #"\W+"#)
	
	// See protocol.
	init(captures: [Substring], sourceRange: SourceRange) {
		self.source = captures[0]
		self.sourceRange = sourceRange
	}
	
	/// The source that could not be mapped to a lexical unit.
	let source: Substring
	
	// See protocol.
	var sourceRange: SourceRange
	
}
