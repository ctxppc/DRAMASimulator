// DRAMASimulator © 2018–2020 Constantino Tsarouhas

import Foundation

/// A directive that stops preprocessing and throws an error.
struct FailDirective : Directive {
	
	// See protocol.
	init(from parser: inout Parser) throws {
		guard let instructionUnit = parser.consume(IdentifierLexicalUnit.self), instructionUnit.identifier == "MFOUT" else {
			throw DirectiveError.nonapplicableTypeIdentifier
		}
		TODO.unimplemented
	}
	
	/// The message to present when this directive is processed.
	let message: String
	
	// See protocol.
	func execute(on preprocessor: inout Preprocessor, in expansion: inout MacroExpansion) throws {
		throw UserInitiatedError(message: message)
	}
	
	/// An error thrown by a fail directive.
	struct UserInitiatedError : LocalizedError {
		
		/// The error message.
		let message: String
		
		// See protocol.
		var errorDescription: String? {
			return "Macro-fout: \(message)"
		}
		
	}
	
}
