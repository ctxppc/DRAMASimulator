// DRAMASimulator © 2018–2020 Constantino Tsarouhas

import Foundation

/// A parsed script that can be readily converted into machine words.
///
/// A program is created from an array of statements and a mapping of symbols to indices in that array.
struct Program {
	
	/// Creates an empty program.
	init() {
		words = []
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
		
		var addressesByStatementIndex: [Int : Int] = [:]
		var nextAddress = 0
		for (statementIndex, statement) in statements.enumerated() {
			addressesByStatementIndex[statementIndex] = nextAddress
			nextAddress += statement.wordCount
		}
		
		guard nextAddress < AddressWord.unsignedUpperBound else { throw AssemblyError.overflow }
		
		var addressesBySymbol: [Script.Symbol : Int] = [:]
		for (symbol, statementIndex) in statementIndicesBySymbol {
			addressesBySymbol[symbol] = addressesByStatementIndex[statementIndex]
		}
		
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
		
		/// The program does not fit in memory.
		case overflow
		
		// See protocol.
		var errorDescription: String? {
			switch self {
				case .overflow:	return "Programma past niet in geheugen"
			}
		}
		
	}
	
}
