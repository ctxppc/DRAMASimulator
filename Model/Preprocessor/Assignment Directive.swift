// DRAMASimulator © 2018 Constantino Tsarouhas

import Foundation

/// A directive that assigns a value to a symbol.
struct AssignmentDirective : Directive {
	
	/// The symbol being assigned a value to.
	let symbol: String
	
	/// An expression that evaluates to the assigned value.
	let expression: NSExpression
	
	// See protocol.
	let fullSourceRange: SourceRange
	
	/// The range in the unprocessed source where the directive's instruction is written.
	let instructionRange: SourceRange
	
	/// The range in the unprocessed source where `symbol` is written.
	let symbolRange: SourceRange
	
	/// The range in the unprocessed source where `expression` is written.
	let expressionRange: SourceRange
	
}
