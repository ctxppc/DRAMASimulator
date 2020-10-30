// DRAMASimulator © 2020 Constantino Tsarouhas

import Foundation

/// A lexical unit for a label, e.g., `endIf:`.
struct LabelLexicalUnit : LexicalUnit {
	
	// See protocol.
	static let pattern = try! NSRegularExpression(pattern: #"(\w+):"#)
	
	// See protocol.
	init(captures: [Substring], sourceRange: SourceRange) {
		self.symbol = .init(captures[1])
		self.sourceRange = sourceRange
	}
	
	/// The register.
	let symbol: String
	
	// See protocol.
	let sourceRange: SourceRange
	
}
