// DRAMASimulator © 2020 Constantino Tsarouhas

import Foundation

/// A lexical unit for a symbol that scopes an index register, i.e., `(` or `)`.
enum IndexRegisterScopeLexicalUnit : LexicalUnit {
	
	// See protocol.
	static let pattern = try! NSRegularExpression(pattern: #"[()]"#)
	
	// See protocol.
	init(captures: [Substring], sourceRange: SourceRange) {
		self = captures[0] == "("
			? .open(sourceRange: sourceRange)
			: .close(sourceRange: sourceRange)
	}
	
	/// The open scope unit.
	case open(sourceRange: SourceRange)
	
	/// The close scope unit.
	case close(sourceRange: SourceRange)
	
	// See protocol.
	var sourceRange: SourceRange {
		switch self {
			case .open(sourceRange: let range), .close(sourceRange: let range):	return range
		}
	}
	
}
