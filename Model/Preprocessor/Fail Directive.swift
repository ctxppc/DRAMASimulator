// DRAMASimulator © 2018 Constantino Tsarouhas

import Foundation

/// A directive that stops preprocessing and throws an error.
struct FailDirective : Directive {
	
	// See protocol.
	static let regularExpression = NSRegularExpression()	// TODO
	
	// See protocol.
	init(match: NSTextCheckingResult, in source: String) throws {
		fatalError("Unimplemented")	// TODO
	}
	
	/// The message to present when this directive is processed.
	let message: String
	
	// See protocol.
	let fullSourceRange: SourceRange
	
	/// The range in the unprocessed source where the directive's instruction is written.
	let instructionRange: SourceRange
	
	/// The range in the unprocessed source where `message` is written.
	let messageRange: SourceRange
	
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
