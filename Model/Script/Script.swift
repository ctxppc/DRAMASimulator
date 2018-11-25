// DRAMASimulator © 2018 Constantino Tsarouhas

import Foundation

/// A document parsed into statements.
struct Script {
	
	/// Parses a script from given text.
	init(from text: String = "") {
		
		storedText = text
		
		var script = self	// shadow copy because `enumerateSubstrings` declares an escaping closure that doesn't really escape
		defer { self = script }
		
		func processStatement(in range: Range<String.Index>) {
			
			let partialStatement: PartialStatement
			do {
				guard let statement = try Statement(from: text[range]) else { return }
				partialStatement = .statement(statement)
				syntaxMap.combine(with: statement.syntaxMap)
			} catch {
				partialStatement = .error(.init(underlyingError: error, range: range))
			}
			
			script.sourceRangeByStatementIndex[self.partialStatements.endIndex] = range
			script.partialStatements.append(partialStatement)
			
		}
		
		text.enumerateSubstrings(in: text.startIndex..<text.endIndex, options: .byLines) { _, range, _, _ in
			if let match = Script.symbolExpression.firstMatch(in: text, range: NSRange(range, in: text)) {
				do {
					
					let symbolRange = Range(match.range(at: 1), in: text)!
					let remainderRange = Range(match.range(at: 2), in: text)!
					let symbol = String(text[symbolRange])
					guard !script.statementIndicesBySymbol.keys.contains(symbol) else { throw SymbolError.duplicateSymbol(symbol) }
					
					script.statementIndicesBySymbol[symbol] = script.partialStatements.endIndex
					processStatement(in: remainderRange)
					
				} catch {
					script.sourceRangeByStatementIndex[script.partialStatements.endIndex] = range
					script.partialStatements.append(.error(.init(underlyingError: error, range: range)))
				}
			} else {
				processStatement(in: range)
			}
		}
		
	}
	
	/// The script's source text.
	var text: String {
		get { return storedText }
		set { self = .init(from: newValue) }
	}
	
	/// The backing storage for `text`.
	private let storedText: String
	
	/// A regular expression matching a symbol.
	///
	/// Groups: symbol, remainder
	private static let symbolExpression = try! NSRegularExpression(pattern: "^\\s*([A-Z_][A-Z_0-9]*):(.*)$", options: .caseInsensitive)
	
	/// The statements encoded in the script, including partially parsed ones.
	private(set) var partialStatements: [PartialStatement] = []
	enum PartialStatement {
		case statement(Statement)
		case error(SourceError)
	}
	
	/// Returns the script's statements.
	///
	/// - Throws: An error if any statement couldn't be parsed.
	func statements() throws -> [Statement] {
		return try partialStatements.map {
			switch $0 {
				case .statement(let statement):	return statement
				case .error(let error):			throw error
			}
		}
	}
	
	/// Returns the errors found in the script's source.
	func sourceErrors() -> [SourceError] {
		return partialStatements.compactMap {
			switch $0 {
				case .statement:		return nil
				case .error(let error):	return error
			}
		}
	}
	
	/// A dictionary mapping indices in the `statements` array to ranges in the source text.
	private(set) var sourceRangeByStatementIndex: [Int : SourceRange] = [:]
	typealias SourceRange = Range<String.Index>
	
	/// A dictionary mapping symbols to indices in the `statements` array.
	private(set) var statementIndicesBySymbol: [Symbol : Int] = [:]
	typealias Symbol = String
	
	/// The combined syntax map of all statements.
	private(set) var syntaxMap: SyntaxMap = .init()
	
	/// An error related to symbols.
	enum SymbolError : LocalizedError {
		
		/// A symbol is used multiple times.
		///
		/// - Parameter 1: The symbol.
		case duplicateSymbol(String)
		
		// See protocol.
		var errorDescription: String? {
			switch self {
				case .duplicateSymbol(let symbol):	return "‘\(symbol)’ is meermaals gedefinieerd"
			}
		}
		
	}
	
}
