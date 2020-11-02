// DRAMASimulator © 2018–2020 Constantino Tsarouhas

import DepthKit
import Foundation

/// A parsed script that can be readily converted into machine words.
///
/// A program is created from an array of statements and a mapping of symbols to indices in that array.
struct Program {
	
	/// Creates an empty program.
	init() {
		words = []
		statements = []
		statementIndicesByAddress = []
		addressesByStatement = []
	}
	
	/// Assembles a program with given statements and mapping from symbols to statement indices.
	///
	/// - Requires: Every statement index in `statementIndicesBySymbol` is a valid index in the `statements` array.
	///
	/// - Parameter statements: The program's statements.
	/// - Parameter statementIndicesBySymbol: A mapping from symbols to indices in the `statements` array.
	///
	/// - Throws: An error if an undefined symbol is referenced.
	init(statements: [Statement], statementIndicesBySymbol: [String : Int]) throws {
		
		var statementIndicesByAddress: [Int] = []
		var rawAddressesByStatement: [Int] = []
		var addressOfStatement = 0
		for (index, statement) in statements.enumerated() {
			let numberOfWords = statement.wordCount
			statementIndicesByAddress.append(contentsOf: repeatElement(index, count: numberOfWords))
			rawAddressesByStatement.append(addressOfStatement)
			addressOfStatement += numberOfWords
		}
		
		guard addressOfStatement < AddressWord.unsignedUpperBound else { throw AssemblyError.overflow }
		
		var addressesBySymbol: [Script.Symbol : Int] = [:]
		for (symbol, statementIndex) in statementIndicesBySymbol {
			guard rawAddressesByStatement.indices.contains(statementIndex) else { throw Program.AssemblyError.danglingSymbol(symbol: symbol) }
			addressesBySymbol[symbol] = rawAddressesByStatement[statementIndex]
		}
		
		self.statements = statements
		self.statementIndicesByAddress = statementIndicesByAddress
		self.addressesByStatement = rawAddressesByStatement.map { AddressWord(rawValue: $0) !! "Expected valid address" }
		words = try zip(statements, statements.indices).flatMap { statement, index -> AnyCollection<MachineWord> in
			do {
				return try statement.words(addressesBySymbol: addressesBySymbol)
			} catch {
				throw StatementTranslationError(underlyingError: error, statementIndex: index)
			}
		}
		
	}
	
	/// The program's words.
	let words: [MachineWord]
	
	/// The program's statements.
	let statements: [Statement]
	
	/// Returns the statement that provided the word at given address.
	///
	/// - Parameter address: The memory address being queried.
	///
	/// - Returns: The statement that provided the word at `address`, or `nil` if the program doesn't affect the location at `address`.
	func statement(at address: AddressWord) -> Statement? {
		statementIndicesByAddress.indices.contains(address.rawValue) ? statements[statementIndicesByAddress[address.rawValue]] : nil
	}
	
	/// An array of `statements` indices for each word in `words`.
	///
	/// For each valid `words` index `a`, `statementIndicesByWord[a]` produces an index `i` such that `words[a]` is a word that is generated by `statements[i]`.
	///
	/// - Invariant: `statementIndicesByAddress.count == words.count`
	private let statementIndicesByAddress: [Int]
	
	/// Returns the statement that provided the word at given address.
	///
	/// - Parameter address: The memory address being queried.
	///
	/// - Returns: The statement that provided the word at `address`, or `nil` if the program doesn't affect the location at `address`.
	func addressOfStatement(at index: Int) -> AddressWord? {
		addressesByStatement.indices.contains(index) ? addressesByStatement[index] : nil
	}
	
	/// An array of addresses for each statement in `statements`.
	///
	/// For each valid `statements` index `i`, `addressesByStatement[i]` produces an address `a` such that `words[a.rawValue]` is a word that is generated by `statements[i]`.
	///
	/// - Invariant: `addressesByStatement.count == statements.count`
	private let addressesByStatement: [AddressWord]
	
	/// An error that occured while translating a statement into words.
	struct StatementTranslationError : LocalizedError {
		
		/// The error that occurred while translating the statement.
		let underlyingError: Error
		
		/// The index of the statement in the `statements` array.
		let statementIndex: Int
		
		// See protocol.
		var errorDescription: String? {
			return (underlyingError as? LocalizedError)?.errorDescription
		}
		
	}
	
	/// An error related to assembly such as memory management or command lowering.
	enum AssemblyError : LocalizedError {
		
		/// A symbol refers to memory without content.
		case danglingSymbol(symbol: String)
		
		/// The program does not fit in memory.
		case overflow
		
		// See protocol.
		var errorDescription: String? {
			switch self {
				case .overflow:						return "Programma past niet in geheugen"
				case .danglingSymbol(let symbol):	return "“\(symbol)” verwijst naar niet-gedefiniëerd geheugen"
			}
		}
		
	}
	
}