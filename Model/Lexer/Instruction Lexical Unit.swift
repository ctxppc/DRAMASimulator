// DRAMASimulator © 2020 Constantino Tsarouhas

import Foundation

/// A lexical unit for an instruction or directive, e.g., `HIA` or `RESGR`.
struct InstructionLexicalUnit : LexicalUnit {
	
	// See protocol.
	static let pattern = try! NSRegularExpression(pattern: #"\w+"#, options: .caseInsensitive)
	
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
