// DRAMASimulator © 2018 Constantino Tsarouhas

import Foundation

/// A lexical unit that could not be parsed.
struct PartialLexicalUnit : LexicalUnit {
	
	// See protocol.
	let fullSourceRange: SourceRange
	
	/// The error.
	let error: Error
	
}
