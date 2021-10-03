// DRAMASimulator © 2020 Constantino Tsarouhas

import DepthKit
import Foundation

/// A sequence of lexemes, produced from a source text by a lexer.
struct SourceUnit {
	
	/// Produces a source unit from a source text.
	init(from sourceText: String) throws {
		self.init(lexemes: Lexer(from: sourceText).lexemes)
	}
	
	/// Creates a source unit with given lexemes.
	init(lexemes: [Lexeme]) {
		self.lexemes = lexemes
	}
	
	/// The lexemes in the source.
	let lexemes: Lexemes
	typealias Lexemes = [Lexeme]
	
	/// Accesses a lexeme.
	subscript (index: Lexemes.Index) -> Lexeme {
		lexemes[index]
	}
	
}
