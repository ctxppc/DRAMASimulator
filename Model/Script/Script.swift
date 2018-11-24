// DRAMASimulator © 2018 Constantino Tsarouhas

import Foundation

/// A parsed script.
struct Script {
	
	/// Creates an empty script.
	init() {
		statements = []
		statementIndexBySymbol = [:]
		lineIndexByStatementIndex = [:]
	}
	
	/// Parses a script from given text.
	init(from text: String) throws {
		
		self.init()
		
		for (lineIndex, line) in text.components(separatedBy: .newlines).enumerated() {
			
			func processStatement(from line: String) throws {
				guard let statement = try Statement(from: line, lineIndex: lineIndex) else { return }
				lineIndexByStatementIndex[statements.endIndex] = lineIndex
				statements.append(statement)
			}
			
			if let match = Script.symbolExpression.firstMatch(in: line, range: NSRange(location: 0, length: (line as NSString).length)) {
				
				let symbol = (line as NSString).substring(with: match.range(at: 1))
				let remainder = (line as NSString).substring(with: match.range(at: 2))
				guard !statementIndexBySymbol.keys.contains(symbol) else { throw SymbolError.duplicateSymbol(symbol, lineIndex: lineIndex) }
				
				statementIndexBySymbol[symbol] = statements.endIndex
				try processStatement(from: remainder)
				
			} else {
				try processStatement(from: line)
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
	
	/// A dictionary mapping indices in the `statements` array to line indices.
	var lineIndexByStatementIndex: [Statements.Index : Int]
	
	/// A dictionary mapping symbols to indices in the `statements` array.
	var statementIndexBySymbol: [Symbol : Statements.Index]
	typealias Symbol = String
	
	/// An error related to symbols.
	enum SymbolError : LocalizedError, SourceError {
		
		/// A symbol is used multiple times.
		///
		/// - Parameter 1: The symbol.
		/// - Parameter lineIndex: The line index.
		case duplicateSymbol(String, lineIndex: Int)
		
		// See protocol.
		var errorDescription: String? {
			switch self {
				case .duplicateSymbol(let symbol, lineIndex: _):	return "‘\(symbol)’ is meermaals gedefinieerd"
			}
		}
		
		// See protocol.
		var lineIndex: Int {
			switch self {
				case .duplicateSymbol(_, lineIndex: let lineIndex):	return lineIndex
			}
		}
		
	}
	
}
