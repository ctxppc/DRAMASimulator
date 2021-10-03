// DRAMASimulator © 2018–2021 Constantino Tsarouhas

import Foundation

/// A directive that assigns a value to a symbol.
struct AssignmentDirective : Directive {
	
	// See protocol.
	init(from parser: inout Parser) throws {
		guard let instructionUnit = parser.consume(IdentifierLexeme.self), instructionUnit.identifier == "MEVA" else {
			throw DirectiveError.nonapplicableTypeIdentifier
		}
		TODO.unimplemented
	}
	
	/// The symbol being assigned a value to.
	let symbol: String
	
	/// An expression that evaluates to the assigned value.
	let expression: NSExpression
	
	// See protocol.
	func execute(on preprocessor: inout Preprocessor, in expansion: inout MacroExpansion) throws {
		TODO.unimplemented
	}
	
}
