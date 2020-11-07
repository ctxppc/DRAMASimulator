// DRAMASimulator © 2018–2020 Constantino Tsarouhas

import Foundation

/// A directive that performs a jump.
struct JumpDirective : Directive {
	
	// See protocol.
	static let regularExpression = NSRegularExpression()	// TODO
	
	// See protocol.
	init(match: NSTextCheckingResult, in source: String) throws {
		fatalError("Unimplemented")	// TODO
	}
	
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
	
	// See protocol.
	func execute(on preprocessor: inout Preprocessor, in expansion: inout MacroExpansion) throws {
		fatalError("Unimplemented")	// TODO
	}
	
}
