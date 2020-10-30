// DRAMASimulator © 2020 Constantino Tsarouhas

import Foundation

/// A construct that can be converted into words.
protocol Statement {
	
	/// Creates a statement from the lexical units extracted by given lexer.
	///
	/// Modifications to `lexer` should be discarded if this initialiser throws an error.
	///
	/// - Parameter lexer: The lexer with which to extract lexical units.
	///
	/// - Throws: An error if the statement couldn't be parsed.
	init?(from lexer: inout Lexer) throws
	
	/// The lexical units that form the statement, in source order.
	///
	/// - Invariant: `lexicalUnits` is nonempty.
	/// - Invariant: Every unit in `lexicalUnits` has increasing and nonoverlapping source range.
	var lexicalUnits: [LexicalUnit] { get }
	
	/// The number of machine words used by the statement.
	var wordCount: Int { get }
	
	/// Translates the statement into words.
	///
	/// - Postcondition: `words(addressesBySymbol: m).length == wordCount` for any valid mapping `m`.
	///
	/// - Parameter addressesBySymbol: A mapping of symbols to absolute addresses.
	///
	/// - Throws: An error if an undefined symbol is used.
	///
	/// - Returns: A collection of words that can be loaded into a machine.
	func words(addressesBySymbol: [String : Int]) throws -> AnyCollection<MachineWord>
	
}

extension Statement {
	
	/// The source range forming the statement.
	var sourceRange: SourceRange {
		guard let first = lexicalUnits.first, let last = lexicalUnits.last else { preconditionFailure("Statement with no lexical units") }
		return first.sourceRange.lowerBound..<last.sourceRange.upperBound
	}
	
}
