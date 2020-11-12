// DRAMASimulator © 2020 Constantino Tsarouhas

import Foundation

/// A value that parses a construct from lexical units.
///
/// Parsing is done in a top-down fashion, with any subconstructs parsed by subparsers and attempting multiple construct types in contexts where multiple are possible.
///
/// A parser stores the deepest error thrown during parsing.
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
	
	/// The lexical units that haven't been processed yet.
	private var unprocessedLexicalUnits: LexicalUnits.SubSequence {
		lexicalUnits[indexOfNextLexicalUnit...]
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
	
	/// A Boolean value indicating whether the parser has unprocessed lexical units.
	var hasUnprocessedLexicalUnits: Bool {
		!unprocessedLexicalUnits.isEmpty
	}
	
	/// Parses a construct of given type.
	///
	/// The parser is unaffected if the construct could not be parsed.
	///
	/// - Parameter type: The type of construct to parse.
	///
	/// - Throws: If no construct could be parsed, an `Error` containing the cause and location of the parse error.
	///
	/// - Returns: A construct.
	mutating func parse<C : Construct>(_ type: C.Type) throws -> C {
		do {
			var subparser = self
			subparser.consumedLexicalUnitsIndexRange = indexOfNextLexicalUnit..<indexOfNextLexicalUnit
			let construct = try C(from: &subparser)
			self.indexOfNextLexicalUnit = subparser.indexOfNextLexicalUnit
			return construct
		} catch let error as Error {
			throw error
		} catch {
			throw Error(cause: error, location: indexOfNextLexicalUnit)
		}
	}
	
	/// Consumes and returns a lexical unit of given type.
	///
	/// The parser is unaffected if the next lexical unit is not of type `Unit` or if there is no unit available.
	///
	/// - Parameter type: The type of lexical unit.
	///
	/// - Returns: A lexical unit of type `Unit`, or `nil` if the next unit isn't of type `Unit` or if there is no unit available.
	mutating func consume<Unit : LexicalUnit>(_ type: Unit.Type) -> Unit? {
		guard let unit = unprocessedLexicalUnits.first as? Unit else { return nil }
		lexicalUnits.formIndex(after: &indexOfNextLexicalUnit)
		return unit
	}
	
	/// Consumes lexical units until a lexical unit is reached for which the given predicate returns `true`.
	///
	/// The lexical unit for which `predicate` returns `true` is not consumed.
	///
	/// - Parameter predicate: A function that determines whether to consume the given lexical unit and continue.
	///
	/// - Returns: The consumed lexical units.
	mutating func consume(until predicate: (LexicalUnit) -> Bool) -> LexicalUnits.SubSequence {
		let indexOfFirstExcludedIndex = unprocessedLexicalUnits.firstIndex(where: predicate) ?? lexicalUnits.endIndex
		let consumed = lexicalUnits[indexOfNextLexicalUnit..<indexOfFirstExcludedIndex]
		indexOfNextLexicalUnit = indexOfFirstExcludedIndex
		return consumed
	}
	
	/// An error thrown during parsing.
	struct Error : LocalizedError, Comparable {
		
		/// The error that caused the parse to fail.
		var cause: Swift.Error
		
		/// The location in the lexical unit stream where the error is thrown.
		var location: LexicalUnits.Index
		
		// See protocol.
		var errorDescription: String? {
			(cause as? LocalizedError)?.errorDescription
		}
		
		// See protocol.
		static func == (first: Self, other: Self) -> Bool {
			first.location == other.location
		}
		
		// See protocol.
		static func < (first: Self, other: Self) -> Bool {
			first.location < other.location
		}
		
	}
	
}
