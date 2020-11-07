// DRAMASimulator © 2020 Constantino Tsarouhas

import Foundation

/// A statement that represents a value to be stored in memory.
struct ValueStatement : Statement {
	
	// See protocol.
	init(from parser: inout Parser) throws {
		guard let unit = parser.consume(LiteralLexicalUnit.self) else { throw Error.invalidFormat }
		self.word = .init(wrapping: unit.value)
		self.lexicalUnits = .init(parser.consumedLexicalUnits)
	}
	
	/// The stored word.
	let word: MachineWord
	
	// See protocol.
	let lexicalUnits: [LexicalUnit]
	
	// See protocol.
	let wordCount = 1
	
	// See protocol.
	func words(addressesBySymbol: [String : Int]) throws -> AnyCollection<MachineWord> {
		return .init(CollectionOfOne(word))
	}
	
	enum Error : Swift.Error {
		case invalidFormat
	}
	
}
