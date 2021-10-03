// DRAMASimulator © 2020 Constantino Tsarouhas

import Foundation

/// A lexeme separating arguments to a command or directive.
struct ArgumentSeparatorLexeme : Lexeme {
	
	// See protocol.
	static let pattern = try! NSRegularExpression(pattern: #","#)
	
	// See protocol.
	init(captures: [Substring], sourceRange: SourceRange) {
		self.sourceRange = sourceRange
	}
	
	// See protocol.
	let sourceRange: SourceRange
	
}
