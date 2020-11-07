// DRAMASimulator © 2020 Constantino Tsarouhas

import Foundation

/// A lexical unit separating arguments to a command or directive.
struct ArgumentSeparatorLexicalUnit : LexicalUnit {
	
	// See protocol.
	static let pattern = try! NSRegularExpression(pattern: #","#)
	
	// See protocol.
	init(captures: [Substring], sourceRange: SourceRange) {
		self.sourceRange = sourceRange
	}
	
	// See protocol.
	let sourceRange: SourceRange
	
}
