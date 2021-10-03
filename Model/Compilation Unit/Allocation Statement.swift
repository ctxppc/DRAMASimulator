// DRAMASimulator © 2020 Constantino Tsarouhas

import Foundation

/// A statement that represents memory to be allocated.
struct AllocationStatement : Statement {
	
	// See protocol.
	init(from parser: inout Parser) throws {
		guard let directiveUnit = parser.consume(IdentifierLexeme.self), directiveUnit.identifier == "RESGR" else { throw Error.unrecognisedDirective }
		guard let sizeUnit = parser.consume(LiteralLexeme.self) else { throw Error.invalidSize }
		self.size = sizeUnit.value
		self.lexemes = .init(parser.consumedLexemes)
		self.directiveLexeme = directiveUnit
		self.sizeLexeme = sizeUnit
	}
	
	/// The size to allocate.
	let size: Int
	
	// See protocol.
	let lexemes: [Lexeme]
	
	/// The lexeme representing the directive.
	let directiveLexeme: IdentifierLexeme
	
	/// The lexeme representing the size argument.
	let sizeLexeme: LiteralLexeme
	
	// See protocol.
	let wordCount = 1
	
	// See protocol.
	func words(addressesBySymbol: [String : Int]) throws -> AnyCollection<MachineWord> {
		return .init(repeatElement(.zero, count: size))
	}
	
	enum Error : Swift.Error {
		case unrecognisedDirective
		case invalidSize
	}
	
}
