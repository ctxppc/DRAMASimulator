// DRAMASimulator © 2018–2020 Constantino Tsarouhas

import Foundation

/// A lexical unit that could not be parsed.
struct PartialLexicalUnit : LexicalUnit, SourceError {
	
	// See protocol.
	let sourceRange: SourceRange
	
	/// The error.
	let error: Error
	
}

extension PartialLexicalUnit : LocalizedError {
	var errorDescription: String? { (error as? LocalizedError)?.errorDescription }
}
