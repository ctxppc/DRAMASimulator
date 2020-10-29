// DRAMASimulator © 2020 Constantino Tsarouhas

import Foundation

/// A lexical unit for a literal value, e.g., `-50`.
struct LiteralLexicalUnit : LexicalUnit {
	
	// See protocol.
	static let pattern = try! NSRegularExpression(pattern: #"-?\d+"#)
	
	// See protocol.
	init?(captures: [Substring], sourceRange: SourceRange) {
		guard let value = Int(captures[1]) else { return nil }
		self.value = value
		self.sourceRange = sourceRange
	}
	
	/// The register.
	let value: Int
	
	// See protocol.
	var sourceRange: SourceRange
	
}
