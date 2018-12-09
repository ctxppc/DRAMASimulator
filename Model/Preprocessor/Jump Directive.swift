// DRAMASimulator © 2018 Constantino Tsarouhas

import Foundation

/// A directive that performs a jump.
struct JumpDirective : Directive {
	
	/// The symbol of the destination directive.
	let destinationSymbol: String
	
	/// The condition, or `nil` if the jump is unconditional.
	let condition: Condition?
	
	// See protocol.
	let fullSourceRange: SourceRange
	
	/// The range in the unprocessed source where the directive's instruction is written.
	let instructionRange: SourceRange
	
	/// The range in the unprocessed source where `destinationSymbol` is written.
	let destinationSymbolRange: SourceRange
	
	/// The range in the unprocessed source where `condition` is written, or `nil` if the jump is unconditional.
	let conditionRange: SourceRange?
	
}
