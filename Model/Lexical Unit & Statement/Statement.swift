// DRAMASimulator © 2018 Constantino Tsarouhas

import Foundation

/// A human-readable encoded command or directive.
///
/// Statements are mapped to zero or more words and loaded sequentially to memory.
protocol Statement : LexicalUnit {
	
	/// A regular expression matching a lexical unit of this type.
	static var regularExpression: NSRegularExpression { get }
	
	/// Initialises the lexical unit with given match.
	///
	/// - Requires: `match` is produced by `Self.regularExpression`.
	///
	/// - Throws: An error if the matched groups cannot be interpreted.
	init(match: NSTextCheckingResult, in source: String) throws
	
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
	func words(addressesBySymbol: [String : Int]) throws -> AnyCollection<Word>
	
}