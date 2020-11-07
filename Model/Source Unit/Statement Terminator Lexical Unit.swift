// DRAMASimulator © 2020 Constantino Tsarouhas

import Foundation

/// A lexical unit representing the end of a statement.
struct StatementTerminatorLexicalUnit : LexicalUnit {
	
	// See protocol.
	static let pattern = try! NSRegularExpression(pattern: #"\n|,|;"#)
	
	// See protocol.
	init(captures: [Substring], sourceRange: SourceRange) {
		self.init(sourceRange: sourceRange)
	}
	
	init(sourceRange: SourceRange) {
		self.sourceRange = sourceRange
	}
	
	// See protocol.
	let sourceRange: SourceRange
	
}
