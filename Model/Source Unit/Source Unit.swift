// DRAMASimulator © 2020 Constantino Tsarouhas

import DepthKit
import Foundation

/// A sequence of lexical units, produced from a source text by a lexer.
struct SourceUnit {
	
	/// Produces a source unit from a source text.
	init(from sourceText: String) throws {
		self.init(lexicalUnits: Lexer(from: sourceText).lexicalUnits)
	}
	
	/// Creates a source unit with given lexical units.
	init(lexicalUnits: [LexicalUnit]) {
		self.lexicalUnits = lexicalUnits
	}
	
	/// The lexical units in the source.
	let lexicalUnits: LexicalUnits
	typealias LexicalUnits = [LexicalUnit]
	
	/// Accesses a lexical unit.
	subscript (index: LexicalUnits.Index) -> LexicalUnit {
		lexicalUnits[index]
	}
	
}
