// DRAMASimulator © 2018 Constantino Tsarouhas

import Foundation

/// A directive that invokes a macro.
struct InvocationDirective : Directive {
	
	// See protocol.
	static let regularExpression = NSRegularExpression()	// TODO
	
	// See protocol.
	init(match: NSTextCheckingResult, in source: String) throws {
		fatalError("Unimplemented")	// TODO
	}
	
	/// The name of the macro to invoke.
	let macroName: String
	
	/// The expressions of the arguments.
	let argumentExpressions: [NSExpression]
	
	// See protocol.
	let fullSourceRange: SourceRange
	
	/// The range in the unprocessed source where `macroName` is written.
	let macroNameRange: SourceRange
	
	/// The ranges in the unprocessed source where the argument expressions are written.
	let argumentExpressionRanges: [SourceRange]
	
	/// Executes the directive on given preprocessor, outside of any macro expansion.
	///
	/// - Note: The preprocessor automatically removes the directive from the source, i.e., the source substring at `fullSourceRange` is replaced by the empty string.
	func execute(on preprocessor: inout Preprocessor) throws {
		fatalError("Unimplemented")	// TODO
	}
	
	// See protocol.
	func execute(on preprocessor: inout Preprocessor, in expansion: inout MacroExpansion) throws {
		fatalError("Unimplemented")	// TODO
	}
	
}
