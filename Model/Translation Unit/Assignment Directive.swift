// DRAMASimulator © 2018–2020 Constantino Tsarouhas

import Foundation

/// A directive that assigns a value to a symbol.
struct AssignmentDirective : Directive {
	
	// See protocol.
	static let regularExpression = NSRegularExpression()	// TODO
	
	// See protocol.
	init(match: NSTextCheckingResult, in source: String) throws {
		fatalError("Unimplemented")	// TODO
	}
	
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
	
	// See protocol.
	func execute(on preprocessor: inout Preprocessor, in expansion: inout MacroExpansion) throws {
		fatalError("Unimplemented")	// TODO
	}
	
}
