// DRAMASimulator © 2018–2020 Constantino Tsarouhas

import Foundation

/// A lexical unit having the form of a label.
struct _LabelLexicalUnit : _LexicalUnit {
	
	/// A regular expression matching a label and the remainder.
	static let regularExpression = NSRegularExpression(anchored: false, .group(.group(.symbolPattern), .optSpace, ":"), .group(".*"))
	
	// See protocol.
	let sourceRange: SourceRange
	
	/// The range in the source where the symbol is written, excluding the label terminator `:`.
	let symbolRange: SourceRange
	
}