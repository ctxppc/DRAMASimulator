// DRAMASimulator © 2020 Constantino Tsarouhas

import Foundation

/// A lexeme representing a comment.
struct CommentLexeme : Lexeme {
	
	// See protocol.
	static let pattern = try! NSRegularExpression(pattern: #"\|.*"#)
	
	// See protocol.
	init(captures: [Substring], sourceRange: SourceRange) {
		self.sourceRange = sourceRange
	}
	
	// See protocol.
	let sourceRange: SourceRange
	
}
