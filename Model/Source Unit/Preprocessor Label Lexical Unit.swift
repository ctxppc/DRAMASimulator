// DRAMASimulator © 2020 Constantino Tsarouhas

import Foundation

/// A lexical unit for a preprocessor label, e.g., `$ok`.
struct PreprocessorLabelLexicalUnit : LexicalUnit {
	
	// See protocol.
	static let pattern = try! NSRegularExpression(pattern: #"$([\w\d]+)"#, options: .caseInsensitive)
	
	// See protocol.
	init(captures: [Substring], sourceRange: SourceRange) {
		self.identifier = .init(captures[1])
		self.sourceRange = sourceRange
	}
	
	/// The name of the label, without prefix.
	let identifier: String
	
	// See protocol.
	let sourceRange: SourceRange
	
}
