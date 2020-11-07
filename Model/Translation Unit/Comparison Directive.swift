// DRAMASimulator © 2018–2020 Constantino Tsarouhas

import Foundation

/// A directive that compares two values and sets the condition state of the preprocessor accordingly.
struct ComparisonDirective : Directive {
	
	// See protocol.
	init(from parser: inout Parser) throws {
		TODO.unimplemented
	}
	
	/// An expression of the first operand of the comparison.
	let firstOperand: NSExpression
	
	/// An expression of the second operand of the comparison.
	let secondOperand: NSExpression
	
	// See protocol.
	func execute(on preprocessor: inout Preprocessor, in expansion: inout MacroExpansion) throws {
		fatalError("Unimplemented")	// TODO
	}
	
}
