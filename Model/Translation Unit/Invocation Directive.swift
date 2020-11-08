// DRAMASimulator © 2018–2020 Constantino Tsarouhas

import Foundation

/// A directive that invokes a macro.
struct InvocationDirective : Directive {
	
	// See protocol.
	init(from parser: inout Parser) throws {
		guard let identifierUnit = parser.consume(IdentifierLexicalUnit.self) else { throw DirectiveError.nonapplicableTypeIdentifier }
		self.macroName = identifierUnit.identifier
		TODO.unimplemented
	}
	
	/// The name of the macro to invoke.
	let macroName: String
	
	/// The expressions of the arguments.
	let argumentExpressions: [NSExpression]
	
	/// Executes the directive on given preprocessor, outside of any macro expansion.
	///
	/// - Note: The preprocessor automatically removes the directive from the source, i.e., the source substring at `fullSourceRange` is replaced by the empty string.
	func execute(on preprocessor: inout Preprocessor) throws {
		TODO.unimplemented
	}
	
	// See protocol.
	func execute(on preprocessor: inout Preprocessor, in expansion: inout MacroExpansion) throws {
		TODO.unimplemented
	}
	
}
