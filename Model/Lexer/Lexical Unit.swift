// DRAMASimulator © 2020 Constantino Tsarouhas

import Foundation

/// An atomic part of a source.
protocol LexicalUnit {
	
	/// A pattern matching a lexical unit of this type.
	///
	/// The pattern shouldn't contain any anchors unless they're intrinsically part of the lexical unit.
	static var pattern: NSRegularExpression { get }
	
	/// Creates a lexical unit from given captured substrings, returning `nil` if the substrings cannot be interpreted.
	///
	/// - Requires: The substrings in `captures` map to capture groups in `Self.pattern`, with the first capture being the whole pattern.
	///
	/// - Parameter captures: The captured substrings, starting with the substring captured by the pattern.
	/// - Parameter sourceRange: The range in the original source text.
	init?(captures: [Substring], sourceRange: SourceRange)
	
	/// The range in the source where the lexical unit is written.
	var sourceRange: SourceRange { get }
	
}
