// DRAMASimulator © 2020 Constantino Tsarouhas

import Foundation

/// A value that produces statements from a sequence of lexical units.
///
/// A parser requests lexical units from a lexer and .
struct Parser {
	
	/// Creates a parser from given source text.
	init(from sourceText: String) {
		lexer = .init(for: sourceText)
	}
	
	/// The lexer.
	private var lexer: Lexer
	
}
