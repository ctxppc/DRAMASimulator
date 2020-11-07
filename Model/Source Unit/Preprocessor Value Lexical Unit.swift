// DRAMASimulator © 2020 Constantino Tsarouhas

import Foundation

/// A lexical unit for an accessed preprocessor variable, e.g., `<foo>`.
struct PreprocessorVariableAccessLexicalUnit : LexicalUnit {
	
	// See protocol.
	static let pattern = try! NSRegularExpression(pattern: #"<([\w\d]+)>"#, options: .caseInsensitive)
	
	// See protocol.
	init(captures: [Substring], sourceRange: SourceRange) {
		self.identifier = .init(captures[1])
		self.sourceRange = sourceRange
	}
	
	/// The name of the variable, without angle brackets.
	let identifier: String
	
	// See protocol.
	let sourceRange: SourceRange
	
}
