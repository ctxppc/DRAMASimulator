// DRAMASimulator © 2018 Constantino Tsarouhas

import Foundation

/// A directive that invokes a macro.
struct InvocationDirective : Directive {
	
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
	
}
