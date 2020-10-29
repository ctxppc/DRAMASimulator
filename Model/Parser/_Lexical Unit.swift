// DRAMASimulator © 2018–2020 Constantino Tsarouhas

import Foundation

/// A substring of a source text encoding a statement, comment, or label.
///
/// Lexical units are usually instantiated by scripts.
protocol _LexicalUnit {
	
	/// The range in the source where the (whole) lexical unit is written.
	var sourceRange: SourceRange { get }
	
}
