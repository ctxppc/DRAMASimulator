// DRAMASimulator © 2020 Constantino Tsarouhas

import Foundation

/// A lexical unit for an identifier, e.g., `HIA`, `RESGR`, or `endIf`.
struct IdentifierLexicalUnit : LexicalUnit {
	
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
