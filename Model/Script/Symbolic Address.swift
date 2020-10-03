// DRAMASimulator © 2018–2020 Constantino Tsarouhas

import Foundation

/// An address that may contain a combination of literals and symbols.
///
/// A symbolic address's effective address can be computed if the symbols' addresses are known. This is typically done while lowering statements into machine words.
struct SymbolicAddress {
	
	/// Parses a symbolic address from given string.
	init<S : StringProtocol>(from string: S) throws {
		
		var terms = [Term]()
		var termString = ""
		var negated = false
		func addTerm(nextTermNegated: Bool) throws {
			
			let trimmedTerm = termString.trimmingCharacters(in: .whitespaces)
			if trimmedTerm.isEmpty {
				terms.append(.literal(0, negated: false))
			} else if let literal = Int(trimmedTerm) {
				terms.append(.literal(literal, negated: negated))
			} else {
				terms.append(.symbol(trimmedTerm, negated: negated))
			}
			
			negated = nextTermNegated
			termString = ""
			
		}
		
		for character in string {
			switch character {
				case "+":	try addTerm(nextTermNegated: false)
				case "-":	try addTerm(nextTermNegated: true)
				default:	termString.append(character)
			}
		}
		
		try addTerm(nextTermNegated: false)
		
		self.terms = terms
		
	}
	
	/// The terms of the address.
	///
	/// - Invariant: `terms` is nonempty.
	let terms: [Term]
	
	enum Term {
		
		/// A term specifying a literal value.
		case literal(Int, negated: Bool)
		
		/// A term referencing a symbol.
		case symbol(String, negated: Bool)
		
		/// Returns the effective address given a mapping of symbols to addresses.
		func effectiveAddress(addressesBySymbol: [Script.Symbol : Int]) throws -> Int {
			switch self {
				
				case .literal(let value, negated: let negated):
				return negated ? -value : value
				
				case .symbol(let symbol, negated: let negated):
				guard let address = addressesBySymbol[symbol] else { throw Error.undefinedSymbol(symbol) }
				return negated ? -address : address
				
			}
		}
		
	}
	
	/// Returns the effective address given a mapping of symbols to addresses.
	func effectiveAddress(addressesBySymbol: [Script.Symbol : Int]) throws -> Int {
		return try terms.map { try $0.effectiveAddress(addressesBySymbol: addressesBySymbol) }.reduce(0, +)
	}
	
	enum Error : LocalizedError {
		
		/// An undefined symbol is specified in a symbolic address.
		case undefinedSymbol(Script.Symbol)
		
		// See protocol.
		var errorDescription: String? {
			switch self {
				case .undefinedSymbol(let symbol):	return "“\(symbol)” is niet gedefinieerd"
			}
		}
		
	}
	
}
