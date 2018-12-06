// DRAMASimulator © 2018 Constantino Tsarouhas

import Foundation

/// A lexical unit having the form of a label.
struct LabelLexicalUnit : LexicalUnit {
	
	/// A regular expression matching a label and the remainder.
	static let regularExpression = NSRegularExpression(anchored: false, .group(.group(.symbolPattern), .optSpace, ":"), .group(".*"))
	
	// See protocol.
	let fullSourceRange: SourceRange
	
	/// The range in the source where the symbol is written, excluding the label terminator `:`.
	let symbolRange: SourceRange
	
}
