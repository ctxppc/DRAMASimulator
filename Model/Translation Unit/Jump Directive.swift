// DRAMASimulator © 2018–2020 Constantino Tsarouhas

import Foundation

/// A directive that performs a jump.
struct JumpDirective : Directive {
	
	// See protocol.
	init(from parser: inout Parser) throws {
		TODO.unimplemented
	}
	
	/// The symbol of the destination directive.
	let destinationSymbol: String
	
	/// The condition, or `nil` if the jump is unconditional.
	let condition: Condition?
	
	// See protocol.
	func execute(on preprocessor: inout Preprocessor, in expansion: inout MacroExpansion) throws {
		fatalError("Unimplemented")	// TODO
	}
	
}
