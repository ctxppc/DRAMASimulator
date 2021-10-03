// DRAMASimulator © 2018–2021 Constantino Tsarouhas

import Foundation

/// A directive that does nothing.
struct NullDirective : Directive {
	
	// See protocol.
	init(from parser: inout Parser) throws {
		guard let instructionUnit = parser.consume(IdentifierLexicalUnit.self), instructionUnit.identifier == "MNTS" else {
			throw DirectiveError.nonapplicableTypeIdentifier
		}
		TODO.unimplemented
	}
	
	// See protocol.
	func execute(on preprocessor: inout Preprocessor, in expansion: inout MacroExpansion) throws {}
	
}
