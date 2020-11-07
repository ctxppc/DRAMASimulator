// DRAMASimulator © 2020 Constantino Tsarouhas

import Foundation

extension CommandStatement {
	
	/// An argument to a command.
	enum Argument {
		
		/// A register argument.
		case register(Register, lexicalUnit: RegisterLexicalUnit)
		
		/// An address argument.
		case address(Address, lexicalUnits: [LexicalUnit])
		
		/// A condition argument.
		case condition(Condition, lexicalUnit: ConditionLexicalUnit)
		
		/// An address argument to a command.
		struct Address {
			
			/// The terms that form the address.
			let terms: [Term]
			enum Term {
				
				/// A literal term.
				case literal(Int)
				
				/// A symbolic term.
				case symbol(name: String, positive: Bool)
				
				/// `self`, negated.
				var negated: Self {
					switch self {
						case .literal(let v):									return .literal(-v)
						case .symbol(name: let name, positive: let positive):	return .symbol(name: name, positive: !positive)
					}
				}
				
			}
			
			/// The index register, if any.
			let indexRegister: IndexRegister
			enum IndexRegister {
				case none
				case reading(Register)
				case preincrementing(Register)
				case predecrementing(Register)
				case postincrementing(Register)
				case postdecrementing(Register)
			}
			
		}
		
		/// The lexical units forming the argument.
		var lexicalUnits: [LexicalUnit] {
			switch self {
				case .register(_, lexicalUnit: let unit):	return [unit]
				case .address(_, lexicalUnits: let units):	return units
				case .condition(_, lexicalUnit: let unit):	return [unit]
			}
		}
		
	}
	
}

extension CommandStatement.Argument.Address {
	
	/// Computes the effective address value.
	///
	/// - Parameter addressesBySymbol: A mapping from symbols to addresses in the program.
	///
	/// - Throws: An error if the address references an undefined symbol.
	///
	/// - Returns: The address' effective value.
	func effectiveValue(addressesBySymbol: [String : Int]) throws -> Int {
		try terms.reduce(0) { (partialSum, term) in
			switch term {
				
				case .literal(let value):
				return partialSum + value
					
				case .symbol(name: let name, positive: let positive):
				guard let value = addressesBySymbol[name] else { throw CommandStatement.Error.undefinedSymbol(name) }
				return positive ? partialSum + value : partialSum - value
					
			}
		}
	}
	
}

extension CommandStatement.Argument : Construct {
	init(from parser: inout Parser) throws {
		if let unit = parser.consume(RegisterLexicalUnit.self) {
			self = .register(unit.register, lexicalUnit: unit)
		} else if let unit = parser.consume(ConditionLexicalUnit.self) {
			self = .condition(unit.condition, lexicalUnit: unit)
		} else {
			let address = try parser.parse(Address.self)
			self = .address(address, lexicalUnits: .init(parser.consumedLexicalUnits))
		}
	}
}

extension CommandStatement.Argument.Address : Construct {
	init(from parser: inout Parser) throws {
		
		func parseNextTerm() throws -> Term? {
			
			guard let operatorUnit = parser.consume(ArithmeticOperatorLexicalUnit.self) else { return nil }
			
			let positive: Bool
			switch operatorUnit.arithmeticOperator {
				case .sum:			positive = true
				case .difference:	positive = false
				default:			throw CommandStatement.Error.disallowedAddressOperator
			}
			
			let term = try parser.parse(Term.self)
			return positive ? term : term.negated
			
		}
		
		let terms: [Term] = try {
			var terms = [try parser.parse(Term.self)]
			while let term = try parseNextTerm() {
				terms.append(term)
			}
			return terms
		}()
		
		let indexRegister: IndexRegister
		if let openUnit = parser.consume(IndexRegisterScopeLexicalUnit.self) {
			
			guard case .open = openUnit else { throw CommandStatement.Error.invalidAddressFormat }
			
			let preoperatorUnit = parser.consume(ArithmeticOperatorLexicalUnit.self)
			guard let registerUnit = parser.consume(RegisterLexicalUnit.self) else { throw CommandStatement.Error.invalidAddressFormat }
			let postoperatorUnit = parser.consume(ArithmeticOperatorLexicalUnit.self)
			
			switch (preoperatorUnit?.arithmeticOperator, postoperatorUnit?.arithmeticOperator) {
				case (nil, nil):			indexRegister = .reading(registerUnit.register)
				case (.sum?, nil):			indexRegister = .preincrementing(registerUnit.register)
				case (nil, .sum?):			indexRegister = .postincrementing(registerUnit.register)
				case (.difference?, nil):	indexRegister = .predecrementing(registerUnit.register)
				case (nil, .difference?):	indexRegister = .postdecrementing(registerUnit.register)
				default:					throw CommandStatement.Error.disallowedIndexRegisterOperator
			}
			
			guard case .close = parser.consume(IndexRegisterScopeLexicalUnit.self) else { throw CommandStatement.Error.invalidAddressFormat }
			
		} else {
			indexRegister = .none
		}
		
		self.init(terms: terms, indexRegister: indexRegister)
		
	}
}

extension CommandStatement.Argument.Address.Term : Construct {
	init(from parser: inout Parser) throws {
		if let symbolUnit = parser.consume(IdentifierLexicalUnit.self) {
			self = .symbol(name: symbolUnit.identifier, positive: true)
		} else if let literalUnit = parser.consume(LiteralLexicalUnit.self) {
			self = .literal(literalUnit.value)
		} else {
			throw CommandStatement.Error.invalidAddressFormat
		}
	}
}
