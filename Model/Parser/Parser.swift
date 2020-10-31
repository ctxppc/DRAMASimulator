// DRAMASimulator © 2020 Constantino Tsarouhas

import Foundation

/// A value that extracts a production of some type from lexical units.
struct Parser {
	
	/// Creates a parser from given source text.
	init(from sourceText: String) {
		lexer = .init(for: sourceText)
	}
	
	/// The lexer.
	private var lexer: Lexer
	
}
