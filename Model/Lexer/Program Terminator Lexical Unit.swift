// DRAMASimulator © 2020 Constantino Tsarouhas

import Foundation

/// A lexical unit representing the end of a program, i.e., `EINDPR`.
struct ProgramTerminatorLexicalUnit : LexicalUnit {
	
	// See protocol.
	static let pattern = try! NSRegularExpression(pattern: #"EINDPR.*"#, options: .dotMatchesLineSeparators)
	
	// See protocol.
	init(captures: [Substring], sourceRange: SourceRange) {
		self.sourceRange = sourceRange
	}
	
	// See protocol.
	let sourceRange: SourceRange
	
}
