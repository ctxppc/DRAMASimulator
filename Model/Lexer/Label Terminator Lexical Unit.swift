// DRAMASimulator © 2020 Constantino Tsarouhas

import Foundation

/// A lexical unit for a symbol that specifies that the preceding symbol specifies a label, i.e., a colon.
struct LabelTerminatorLexicalUnit : LexicalUnit {
	
	// See protocol.
	static let pattern = try! NSRegularExpression(pattern: #":"#)
	
	// See protocol.
	init(captures: [Substring], sourceRange: SourceRange) {
		self.sourceRange = sourceRange
	}
	
	// See protocol.
	var sourceRange: SourceRange
	
}
