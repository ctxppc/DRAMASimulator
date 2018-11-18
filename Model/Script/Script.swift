// DRAMASimulator © 2018 Constantino Tsarouhas

import Foundation

/// A parsed script.
struct Script {
	
	/// Parses a script from given text.
	init(from text: String) throws {
		
		statements = []
		statementIndexBySymbol = [:]
		
		for line in text.components(separatedBy: .newlines) {
			if let match = Script.symbolExpression.firstMatch(in: line, range: NSRange(location: 0, length: (line as NSString).length)) {
				
				let symbol = (line as NSString).substring(with: match.range(at: 1))
				guard !statementIndexBySymbol.keys.contains(symbol) else { throw SymbolError.duplicateSymbol(symbol) }
				statementIndexBySymbol[symbol] = statements.endIndex
				
				let remainder = (line as NSString).substring(with: match.range(at: 2))
				if let statement = try Statement(from: remainder) {
					statements.append(statement)
				}
				
			} else {
				if let statement = try Statement(from: line) {
					statements.append(statement)
				}
			}
		}
		
	}
	
	/// A regular expression matching a symbol.
	///
	/// Groups: symbol, remainder
	private static let symbolExpression = try! NSRegularExpression(pattern: "^\\s*([A-Z_][A-Z_0-9]*):(.*)$", options: .caseInsensitive)
	
	/// The statements encoded in the script.
	var statements: [Statement]
	typealias Statements = [Statement]
	
	/// A dictionary mapping symbols to indices in the `statements` array.
	var statementIndexBySymbol: [Symbol : Statements.Index]
	typealias Symbol = String
	
	/// An error related to symbols.
	enum SymbolError : Error {
		
		/// A symbol is used multiple times.
		case duplicateSymbol(String)
		
	}
	
}
