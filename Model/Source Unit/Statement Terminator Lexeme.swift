// DRAMASimulator © 2020 Constantino Tsarouhas

import Foundation

/// A lexeme representing the end of a statement.
struct StatementTerminatorLexeme : Lexeme {
	
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
