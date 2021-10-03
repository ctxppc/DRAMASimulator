// DRAMASimulator © 2020 Constantino Tsarouhas

import Foundation

/// A lexeme for an identifier, e.g., `HIA`, `RESGR`, or `endIf`.
struct IdentifierLexeme : Lexeme {
	
	// See protocol.
	static let pattern = try! NSRegularExpression(pattern: #"\w[\w\d]*"#, options: .caseInsensitive)
	
	// See protocol.
	init(captures: [Substring], sourceRange: SourceRange) {
		self.identifier = .init(captures[0])
		self.sourceRange = sourceRange
	}
	
	/// The instruction.
	let identifier: String
	
	// See protocol.
	let sourceRange: SourceRange
	
}
