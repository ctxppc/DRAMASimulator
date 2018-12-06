// DRAMASimulator © 2018 Constantino Tsarouhas

import Foundation

/// A substring of a source text encoding a statement, comment, or label.
///
/// Lexical units are usually instantiated by scripts.
protocol LexicalUnit {
	
	/// The range in the source where the (whole) lexical unit is written.
	var fullSourceRange: SourceRange { get }
	
}
