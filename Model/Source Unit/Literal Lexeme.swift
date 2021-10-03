// DRAMASimulator © 2020 Constantino Tsarouhas

import Foundation

/// A lexeme for a literal value, e.g., `-50`.
struct LiteralLexeme : Lexeme {
	
	// See protocol.
	static let pattern = try! NSRegularExpression(pattern: #"-?\d+"#)
	
	// See protocol.
	init?(captures: [Substring], sourceRange: SourceRange) {
		guard let value = Int(captures[0]) else { return nil }
		self.value = value
		self.sourceRange = sourceRange
	}
	
	/// The register.
	let value: Int
	
	// See protocol.
	let sourceRange: SourceRange
	
}
