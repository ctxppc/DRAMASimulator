// DRAMASimulator © 2018–2021 Constantino Tsarouhas

import Foundation

/// A directive that performs a jump if a condition holds.
struct ConditionalJumpDirective : Directive {
	
	// See protocol.
	init(from parser: inout Parser) throws {
		guard let instructionUnit = parser.consume(IdentifierLexeme.self), instructionUnit.identifier == "MVSP" else {
			throw DirectiveError.nonapplicableTypeIdentifier
		}
		TODO.unimplemented
	}
	
	/// The symbol of the destination directive.
	let destinationSymbol: String
	
	/// The condition.
	let condition: Condition
	
	// See protocol.
	func execute(on preprocessor: inout Preprocessor, in expansion: inout MacroExpansion) throws {
		TODO.unimplemented
	}
	
}
