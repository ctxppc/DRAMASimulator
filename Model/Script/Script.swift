// DRAMASimulator © 2018 Constantino Tsarouhas

import Foundation

/// A parsed script.
struct Script {
	
	init(from text: String) throws {
		statements = []
		for (lineIndex, statement) in text.components(separatedBy: .newlines).enumerated() {
			// TODO
		}
	}
	
	/// The statements encoded in the script.
	var statements: [Statement]
	
	/// A dictionary mapping symbols to indices in the `statements` array.
	var statementIndexBySymbol: [String : Int]
	
	/// An error related to symbols.
	enum SymbolError : Error {
		
		/// A symbol is used multiple times.
		case duplicateSymbol(lineOfFirstInstance: Int, lineOfSecondInstance: Int)
		
	}
	
}
