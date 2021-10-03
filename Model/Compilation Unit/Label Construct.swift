// DRAMASimulator © 2020 Constantino Tsarouhas

import Foundation

struct LabelConstruct : Construct {
	
	// See protocol.
	init(from parser: inout Parser) throws {
		guard let symbolUnit = parser.consume(IdentifierLexeme.self), let markerUnit = parser.consume(LabelMarkerLexeme.self) else { throw Error.noLabel }
		self.symbol = symbolUnit.identifier
		self.lexemes = [symbolUnit, markerUnit]
	}
	
	/// The symbol.
	let symbol: String
	
	/// The lexemes that form the statement, in source order.
	///
	/// - Invariant: `lexemes` is nonempty.
	/// - Invariant: Every lexeme in `lexemes` has increasing and nonoverlapping source range.
	let lexemes: [Lexeme]
	
	/// An error during parsing.
	enum Error : LocalizedError {
		
		case noLabel
		
		var errorDescription: String? {
			switch self {
				case .noLabel:	return "Etiket verwacht"
			}
		}
		
	}
	
}
