// DRAMASimulator © 2018 Constantino Tsarouhas

import Foundation

/// A directive that does nothing.
struct NullDirective : Directive {
	
	// See protocol.
	static let regularExpression = NSRegularExpression()	// TODO
	
	// See protocol.
	init(match: NSTextCheckingResult, in source: String) throws {
		fatalError("Unimplemented")	// TODO
	}
	
	// See protocol.
	let fullSourceRange: SourceRange
	
	/// The range in the unprocessed source where the directive's instruction is written.
	let instructionRange: SourceRange
	
	// See protocol.
	func execute(on preprocessor: inout Preprocessor, in expansion: inout MacroExpansion) throws {}
	
}
