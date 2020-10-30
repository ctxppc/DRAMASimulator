// DRAMASimulator © 2018–2020 Constantino Tsarouhas

import Foundation

/// A lexical unit containing a comment.
struct _CommentLexicalUnit : _LexicalUnit {
	
	/// A regular expression matching a comment and the remainder.
	static let regularExpression = NSRegularExpression(anchored: false, .group("[^|]*"), .group("\\|.*"))
	
	// See protocol.
	let sourceRange: SourceRange
	
}
