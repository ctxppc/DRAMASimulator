// DRAMASimulator © 2020 Constantino Tsarouhas

import Foundation

struct LabelConstruct : Construct {
	
	// See protocol.
	init(from parser: inout Parser) throws {
		guard let symbolUnit = parser.consume(IdentifierLexicalUnit.self), parser.consume(LabelMarkerLexicalUnit.self) != nil else { throw Error.noLabel }
		self.symbol = symbolUnit.identifier
	}
	
	/// The symbol.
	let symbol: String
	
	/// An error during parsing.
	enum Error : Swift.Error {
		case noLabel
	}
	
}
