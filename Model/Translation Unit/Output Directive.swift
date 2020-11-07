// DRAMASimulator © 2018–2020 Constantino Tsarouhas

import Foundation

/// A directive that outputs the value assigned to a symbol.
///
/// Output directives are written as `<s>` where _s_ is the symbol of the local or global variable whose value is being output.
struct OutputDirective : Directive {
	
	// See protocol.
	static let regularExpression = NSRegularExpression()	// TODO
	
	// See protocol.
	init(match: NSTextCheckingResult, in source: String) throws {
		fatalError("Unimplemented")	// TODO
	}
	
	/// The symbol of the variable whose value is output.
	let symbol: String
	
	// See protocol.
	let fullSourceRange: SourceRange
	
	// See protocol.
	func execute(on preprocessor: inout Preprocessor, in expansion: inout MacroExpansion) throws {
		fatalError("Unimplemented")	// TODO
	}
	
}
