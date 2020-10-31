// DRAMASimulator © 2020 Constantino Tsarouhas

import Foundation

/// A lexical unit for an identifier, e.g., `HIA`, `RESGR`, or `endIf`.
struct IdentifierLexicalUnit : LexicalUnit {
	
	// See protocol.
	static let pattern = try! NSRegularExpression(pattern: #"\w[\w\d]*"#, options: .caseInsensitive)
	
	// See protocol.
	init?(captures: [Substring], sourceRange: SourceRange) {
		guard let instruction = Instruction(rawValue: .init(captures[1])) else { return nil }
		self.instruction = instruction
		self.sourceRange = sourceRange
	}
	
	/// The instruction.
	let instruction: Instruction
	
	// See protocol.
	let sourceRange: SourceRange
	
}
