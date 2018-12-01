// DRAMASimulator © 2018 Constantino Tsarouhas

import Foundation

/// An address that may contain a combination of literals and symbols.
///
/// A symbolic address's effective address can be computed if the symbols' addresses are known. This is typically done while lowering statements into machine words.
struct SymbolicAddress {
	
	/// Parses a symbolic address from given string.
	init<S : StringProtocol>(from string: S) throws where S.Index == String.Index {
		terms = try string.split(separator: "+", omittingEmptySubsequences: false).map { term in
			let term = term.trimmingCharacters(in: .whitespaces)
			guard !term.isEmpty else { throw Error.emptyTerm }
			if let literal = Int(term) {
				return .literal(literal)
			} else {
				return .symbol(term)
			}
		}
	}
	
	/// The terms of the address.
	///
	/// - Invariant: `terms` is nonempty.
	let terms: [Term]
	
	enum Term {
		
		/// A term specifying a literal value.
		case literal(Int)
		
		/// A term referencing a symbol.
		case symbol(String)
		
		/// Returns the effective address given a mapping of symbols to addresses.
		func effectiveAddress(addressesBySymbol: [Script.Symbol : Int]) throws -> Int {
			switch self {
				
				case .literal(let value):
				return value
				
				case .symbol(let symbol):
				guard let address = addressesBySymbol[symbol] else { throw Error.undefinedSymbol(symbol) }
				return address
				
			}
		}
		
	}
	
	/// Returns the effective address given a mapping of symbols to addresses.
	func effectiveAddress(addressesBySymbol: [Script.Symbol : Int]) throws -> Int {
		return try terms.map { try $0.effectiveAddress(addressesBySymbol: addressesBySymbol) }.reduce(0, +)
	}
	
	enum Error : LocalizedError {
		
		/// A term is empty.
		case emptyTerm
		
		/// An undefined symbol is specified in a symbolic address.
		case undefinedSymbol(Script.Symbol)
		
		// See protocol.
		var errorDescription: String? {
			switch self {
				case .emptyTerm:					return "Adresoperand met lege term"
				case .undefinedSymbol(let symbol):	return "“\(symbol)” is niet gedefinieerd"
			}
		}
		
	}
	
}
