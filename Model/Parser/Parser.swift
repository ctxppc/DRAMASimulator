// DRAMASimulator © 2020 Constantino Tsarouhas

import Foundation

/// A value that parses a construct from lexemes.
///
/// Parsing is done in a top-down fashion, with any subconstructs parsed by subparsers and attempting multiple construct types in contexts where multiple are possible.
///
/// A parser stores the deepest error thrown during parsing.
struct Parser {
	
	/// Creates a parser from given source text.
	init(from sourceText: String) {
		self.init(lexemes: Lexer(from: sourceText).lexemes)
	}
	
	/// Creates a parser with given lexemes.
	init(lexemes: Lexemes) {
		self.lexemes = lexemes
		self.consumedLexemesIndexRange = lexemes.startIndex..<lexemes.startIndex
	}
	
	/// The lexemes available to the parser.
	let lexemes: Lexemes
	typealias Lexemes = [Lexeme]
	
	/// The lexemes consumed by the currently parsed construct.
	///
	/// This collection is empty when the parser invokes the parsed construct type's `init(parser:)` initialiser. When the construct is done consuming lexemes, it can access this property to retrieve all lexemes consumed by it or any of its parsed subconstructs.
	var consumedLexemes: Lexemes.SubSequence {
		lexemes[consumedLexemesIndexRange]
	}
	
	/// The lexemes that haven't been processed yet.
	private var unprocessedLexemes: Lexemes.SubSequence {
		lexemes[indexOfNextLexeme...]
	}
	
	/// The index range in `lexemes` consumed by the currently parsed construct.
	///
	/// The range's lower bound is the index of the first lexeme consumed or consumable by the currently parsed construct. The range's upper bound is the index of the next lexeme consumable by the construct. The open range represents the lexemes consumed by the currently parsed construct.
	private var consumedLexemesIndexRange: Range<Lexemes.Index>
	
	/// The index of the next consumable lexeme, or the end index if all units have been consumed.
	private var indexOfNextLexeme: Lexemes.Index {
		get { consumedLexemesIndexRange.upperBound }
		set { consumedLexemesIndexRange = consumedLexemesIndexRange.lowerBound..<newValue }
	}
	
	/// A Boolean value indicating whether the parser has unprocessed lexemes.
	var hasUnprocessedLexemes: Bool {
		!unprocessedLexemes.isEmpty
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
			subparser.consumedLexemesIndexRange = indexOfNextLexeme..<indexOfNextLexeme
			let construct = try C(from: &subparser)
			self.indexOfNextLexeme = subparser.indexOfNextLexeme
			return construct
		} catch let error as Error {
			throw error
		} catch {
			throw Error(cause: error, location: indexOfNextLexeme)
		}
	}
	
	/// Consumes and returns a lexeme of given type.
	///
	/// The parser is unaffected if the next lexeme is not of type `Unit` or if there is no unit available.
	///
	/// - Parameter type: The type of lexeme.
	///
	/// - Returns: A lexeme of type `Unit`, or `nil` if the next unit isn't of type `Unit` or if there is no unit available.
	mutating func consume<Unit : Lexeme>(_ type: Unit.Type) -> Unit? {
		guard let unit = unprocessedLexemes.first as? Unit else { return nil }
		lexemes.formIndex(after: &indexOfNextLexeme)
		return unit
	}
	
	/// Consumes lexemes until a lexeme is reached for which the given predicate returns `true`.
	///
	/// The lexeme for which `predicate` returns `true` is not consumed.
	///
	/// - Parameter predicate: A function that determines whether to consume the given lexeme and continue.
	///
	/// - Returns: The consumed lexemes.
	mutating func consume(until predicate: (Lexeme) -> Bool) -> Lexemes.SubSequence {
		let indexOfFirstExcludedIndex = unprocessedLexemes.firstIndex(where: predicate) ?? lexemes.endIndex
		let consumed = lexemes[indexOfNextLexeme..<indexOfFirstExcludedIndex]
		indexOfNextLexeme = indexOfFirstExcludedIndex
		return consumed
	}
	
	/// An error thrown during parsing.
	struct Error : LocalizedError, Comparable {
		
		/// The error that caused the parse to fail.
		var cause: Swift.Error
		
		/// The location in the lexeme stream where the error is thrown.
		var location: Lexemes.Index
		
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
