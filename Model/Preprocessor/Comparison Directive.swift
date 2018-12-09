// DRAMASimulator © 2018 Constantino Tsarouhas

import Foundation

/// A directive that compares two values and sets the condition state of the preprocessor accordingly.
struct ComparisonDirective : Directive {
	
	/// An expression of the first operand of the comparison.
	let firstOperand: NSExpression
	
	/// An expression of the second operand of the comparison.
	let secondOperand: NSExpression
	
	// See protocol.
	let fullSourceRange: SourceRange
	
	/// The range in the unprocessed source where the directive's instruction is written.
	let instructionRange: SourceRange
	
	/// The range in the unprocessed source where `firstOperand` is written.
	let firstOperandRange: SourceRange
	
	/// The range in the unprocessed source where `secondOperand` is written.
	let secondOperandRange: SourceRange
	
}
