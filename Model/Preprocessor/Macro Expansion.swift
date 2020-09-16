// DRAMASimulator © 2018 Constantino Tsarouhas

import Foundation

/// An instance of a macro being expanded.
struct MacroExpansion {
	
	/// Creates a new expansion of given macro.
	init(of macro: Macro, arguments: [String], expansionIdentifier: Int) {
		self.macro = macro
		self.expansionIdentifier = expansionIdentifier
		valuesBySymbol = Dictionary(uniqueKeysWithValues: arguments.enumerated().map { (macro.parameters[$0], $1) })
	}
	
	/// The macro being expanded.
	let macro: Macro
	
	/// The number used to generate labels unique to this expansion.
	let expansionIdentifier: Int
	
	/// The values assigned to local variables, by symbol.
	private var valuesBySymbol: [String : String]
	
	/// Accesses the value of the local variable with given symbol.
	subscript (valueForSymbol symbol: String) -> String? {
		get { return valuesBySymbol[symbol] }
		set { valuesBySymbol[symbol] = newValue }
	}
	
	/// Performs the expansion in given preprocessor.
	func expand(in preprocessor: inout Preprocessor) throws {
		fatalError("Unimplemented")	// TODO
	}
	
}