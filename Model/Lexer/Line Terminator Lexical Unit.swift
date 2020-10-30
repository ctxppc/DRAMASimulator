// DRAMASimulator © 2020 Constantino Tsarouhas

import Foundation

/// A lexical unit representing a line terminator.
struct LineTerminatorLexicalUnit : LexicalUnit {
	
	// See protocol.
	static let pattern = try! NSRegularExpression(pattern: #"\n"#)
	
	// See protocol.
	init(captures: [Substring], sourceRange: SourceRange) {
		self.sourceRange = sourceRange
	}
	
	// See protocol.
	let sourceRange: SourceRange
	
}
