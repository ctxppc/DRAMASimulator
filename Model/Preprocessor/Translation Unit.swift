// DRAMASimulator © 2020 Constantino Tsarouhas

import Foundation

/// A sequence of lexical units that is being or has been transformed to a form that can be parsed into a compilation unit.
///
/// A translation unit is created from a sequence of lexical units (from a lexer), then transformed by a preprocessor until it no longer contains directives, and finally used as the input for parsing a compilation unit.
///
/// A translation unit is processed one directive or lexical unit at a time, skipping over lexical units that need no further processing, and is considered preprocessed when all lexical units have been processed.
struct TranslationUnit {
	
	/// Creates a translation unit containing lexical units produced by given lexer.
	init(from lexer: Lexer) {
		self.init(lexicalUnits: lexer.lexicalUnits)
	}
	
	/// Creates a translation unit containing given lexical units.
	init(lexicalUnits: LexicalUnits) {
		self.lexicalUnits = lexicalUnits
		self.indexOfNextLexicalUnit = lexicalUnits.startIndex
	}
	
	/// The translation unit's lexical units.
	private(set) var lexicalUnits: LexicalUnits
	typealias LexicalUnits = [LexicalUnit]
	
	/// The index of the next lexical unit to process.
	private var indexOfNextLexicalUnit: LexicalUnits.Index
	
	/// The translation unit's yet to be processed lexical units.
	private var unprocessedLexicalUnits: LexicalUnits.SubSequence {
		lexicalUnits[indexOfNextLexicalUnit...]
	}
	
	/// A Boolean value indicating whether the translation unit is processed into a form that can be parsed into a compilation unit.
	var isProcessed: Bool {
		unprocessedLexicalUnits.isEmpty
	}
	
}
