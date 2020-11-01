// DRAMASimulator © 2020 Constantino Tsarouhas

import Foundation

struct LabelConstruct : Construct {
	
	// See protocol.
	init(from parser: inout Parser) throws {
		guard let symbolUnit = parser.consume(IdentifierLexicalUnit.self), let markerUnit = parser.consume(LabelMarkerLexicalUnit.self) else { throw Error.noLabel }
		self.symbol = symbolUnit.identifier
		self.lexicalUnits = [symbolUnit, markerUnit]
	}
	
	/// The symbol.
	let symbol: String
	
	/// The lexical units that form the statement, in source order.
	///
	/// - Invariant: `lexicalUnits` is nonempty.
	/// - Invariant: Every unit in `lexicalUnits` has increasing and nonoverlapping source range.
	let lexicalUnits: [LexicalUnit]
	
	/// An error during parsing.
	enum Error : Swift.Error {
		case noLabel
	}
	
}
