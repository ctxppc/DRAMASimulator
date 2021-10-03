// DRAMASimulator © 2020 Constantino Tsarouhas

import Foundation

/// An atomic part of a source.
protocol Lexeme {
	
	/// A pattern matching a lexeme of this type.
	///
	/// The pattern shouldn't contain any anchors unless they're intrinsically part of the lexeme.
	static var pattern: NSRegularExpression { get }
	
	/// Creates a lexeme from given captured substrings.
	///
	/// - Requires: The substrings in `captures` map to capture groups in `Self.pattern`, with the first capture being the whole pattern.
	///
	/// - Parameter captures: The captured substrings, starting with the substring captured by the pattern.
	/// - Parameter sourceRange: The range in the original source text.
	///
	/// - Returns: `nil` if no lexeme can be formed with given captures.
	init?(captures: [Substring], sourceRange: SourceRange)
	
	/// The range in the source where the lexeme is written.
	var sourceRange: SourceRange { get }
	
}
