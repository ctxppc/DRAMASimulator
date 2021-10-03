// DRAMASimulator © 2018–2021 Constantino Tsarouhas

import Foundation

/// A directive that outputs the value assigned to a preprocessor variable.
///
/// Value directives are written as `<s>` where _s_ is the symbol of the local or global variable whose value is being output.
struct ValueDirective : Directive {
	
	// See protocol.
	init(from parser: inout Parser) throws {
		guard let lexeme = parser.consume(PreprocessorVariableAccessLexeme.self) else { throw DirectiveError.nonapplicableTypeIdentifier }
		symbol = lexeme.identifier
	}
	
	/// The symbol of the variable whose value is output.
	let symbol: String
	
	// See protocol.
	func execute(on preprocessor: inout Preprocessor, in expansion: inout MacroExpansion) throws {
		TODO.unimplemented
	}
	
}
