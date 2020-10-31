// DRAMASimulator © 2020 Constantino Tsarouhas

import Foundation

/// A value that parses a construct from lexical units.
///
/// Parsing is done in a top-down fashion, with any subconstructs parsed by subparsers and attempting multiple construct types in contexts where multiple are possible.
struct Parser {
	
	/// Creates a parser from given source text.
	init(from sourceText: String) {
		self.init(lexicalUnits: Lexer(from: sourceText).lexicalUnits)
	}
	
	/// Creates a parser with given lexical units.
	init(lexicalUnits: LexicalUnits) {
		self.lexicalUnits = lexicalUnits
		self.consumedLexicalUnitsIndexRange = lexicalUnits.startIndex..<lexicalUnits.startIndex
	}
	
	/// The lexical units available to the parser.
	let lexicalUnits: LexicalUnits
	typealias LexicalUnits = [LexicalUnit]
	
	/// The lexical units consumed by the currently parsed construct.
	///
	/// This collection is empty when the parser invokes the parsed construct type's `init(parser:)` initialiser. When the construct is done consuming lexical units, it can access this property to retrieve all lexical units consumed by it or any of its parsed subconstructs.
	var consumedLexicalUnits: LexicalUnits.SubSequence {
		lexicalUnits[consumedLexicalUnitsIndexRange]
	}
	
	/// The index range in `lexicalUnits` consumed by the currently parsed construct.
	///
	/// The range's lower bound is the index of the first lexical unit consumed or consumable by the currently parsed construct. The range's upper bound is the index of the next lexical unit consumable by the construct. The open range represents the lexical units consumed by the currently parsed construct.
	private var consumedLexicalUnitsIndexRange: Range<LexicalUnits.Index>
	
	/// The index of the next consumable lexical unit, or the end index if all units have been consumed.
	private var indexOfNextLexicalUnit: LexicalUnits.Index {
		get { consumedLexicalUnitsIndexRange.upperBound }
		set { consumedLexicalUnitsIndexRange = consumedLexicalUnitsIndexRange.lowerBound..<newValue }
	}
	
	/// Parses a construct of given type.
	///
	/// The parser is unaffected if the construct could not be parsed.
	///
	/// - Parameter type: The type of construct to parse.
	///
	/// - Throws: An error if no construct could be parsed.
	///
	/// - Returns: A construct.
	mutating func parse<C : Construct>(_ type: C.Type) throws -> C {
		var subparser = makeSubparser()
		let construct = try C(from: &subparser)
		closeSubparser(subparser)
		return construct
	}
	
	/// Returns a parser for parsing a subconstruct.
	private func makeSubparser() -> Self {
		var subparser = self
		subparser.consumedLexicalUnitsIndexRange = indexOfNextLexicalUnit..<indexOfNextLexicalUnit
		return subparser
	}
	
	/// Closes a given subparser, so that `self` skips over the lexical units consumed in the subparser.
	private mutating func closeSubparser(_ subparser: Self) {
		self.indexOfNextLexicalUnit = subparser.indexOfNextLexicalUnit
	}
	
	/// Consumes and returns a lexical unit of given type.
	///
	/// The parser is unaffected if the next lexical unit is not of type `Unit` or if there is no unit available.
	///
	/// - Parameter type: The type of lexical unit.
	///
	/// - Returns: A lexical unit of type `Unit`, or `nil` if the next unit isn't of type `Unit` or if there is no unit available.
	mutating func consume<Unit : LexicalUnit>(_ type: Unit.Type) -> Unit? {
		guard let unit = lexicalUnits[indexOfNextLexicalUnit...].first as? Unit else { return nil }
		lexicalUnits.formIndex(after: &indexOfNextLexicalUnit)
		return unit
	}
	
}
