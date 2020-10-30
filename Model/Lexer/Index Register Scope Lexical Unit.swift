// DRAMASimulator © 2020 Constantino Tsarouhas

import Foundation

/// A lexical unit for a symbol that scopes an index register, i.e., `(` or `)`.
struct IndexRegisterScopeLexicalUnit : LexicalUnit {
	
	// See protocol.
	static let pattern = try! NSRegularExpression(pattern: #"[()]"#)
	
	// See protocol.
	init(captures: [Substring], sourceRange: SourceRange) {
		self.opensScope = captures[0] == "("
		self.sourceRange = sourceRange
	}
	
	/// A Boolean value indicating whether the unit opens an index register scope.
	let opensScope: Bool
	
	// See protocol.
	let sourceRange: SourceRange
	
}
