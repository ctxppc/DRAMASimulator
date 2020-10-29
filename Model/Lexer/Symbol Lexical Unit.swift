// DRAMASimulator © 2020 Constantino Tsarouhas

import Foundation

/// A lexical unit for a symbol, e.g., `endIf`.
struct SymbolLexicalUnit : LexicalUnit {
	
	// See protocol.
	static let pattern = try! NSRegularExpression(pattern: #"\w+"#)
	
	// See protocol.
	init(captures: [Substring], sourceRange: SourceRange) {
		self.symbol = .init(captures[1])
		self.sourceRange = sourceRange
	}
	
	/// The register.
	let symbol: String
	
	// See protocol.
	var sourceRange: SourceRange
	
}
