// DRAMASimulator © 2020 Constantino Tsarouhas

import Foundation

/// A construct that represents a command or some other value to be stored in memory.
protocol Statement : Construct {
	
	/// The lexemes that form the statement, in source order.
	///
	/// - Invariant: `lexemes` is nonempty.
	/// - Invariant: Every lexeme in `lexemes` has increasing and nonoverlapping source range.
	var lexemes: [Lexeme] { get }
	
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
		guard let first = lexemes.first, let last = lexemes.last else { preconditionFailure("Statement with no lexemes") }
		return first.sourceRange.lowerBound..<last.sourceRange.upperBound
	}
	
}
