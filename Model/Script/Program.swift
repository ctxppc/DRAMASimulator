// DRAMASimulator © 2018–2020 Constantino Tsarouhas

import Foundation

/// A parsed script that can be readily converted into machine words.
///
/// A program is created from an array of statements and a mapping of symbols to indices in that array.
struct Program {
	
	/// Creates an empty program.
	init() {
		words = []
		statements = []
		statementIndexByWord = []
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
		
		var statementIndexByWord: [Int] = []
		var nextAddress = 0
		for statement in statements {
			statementIndexByWord.append(nextAddress)
			nextAddress += statement.wordCount
		}
		
		guard nextAddress < AddressWord.unsignedUpperBound else { throw AssemblyError.overflow }
		
		var addressesBySymbol: [Script.Symbol : Int] = [:]
		for (symbol, statementIndex) in statementIndicesBySymbol {
			guard statementIndexByWord.indices.contains(statementIndex) else { throw Program.AssemblyError.danglingSymbol(symbol: symbol) }
			addressesBySymbol[symbol] = statementIndexByWord[statementIndex]
		}
		
		self.statements = statements
		self.statementIndexByWord = statementIndexByWord
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
	
	/// An array mapping each word to an index in `statements`.
	///
	/// - Invariant: `statementIndexByWord.count == words.count`
	let statementIndexByWord: [Int]
	
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
