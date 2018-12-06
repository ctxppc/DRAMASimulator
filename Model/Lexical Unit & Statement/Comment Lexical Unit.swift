// DRAMASimulator © 2018 Constantino Tsarouhas

import Foundation

/// A lexical unit containing a comment.
struct CommentLexicalUnit : LexicalUnit {
	
	/// A regular expression matching a comment and the remainder.
	static let regularExpression = NSRegularExpression(anchored: false, .group("[^|]*"), .group("\\|.*"))
	
	// See protocol.
	let fullSourceRange: SourceRange
	
}
