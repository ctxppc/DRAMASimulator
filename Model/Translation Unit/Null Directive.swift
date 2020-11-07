// DRAMASimulator © 2018–2020 Constantino Tsarouhas

import Foundation

/// A directive that does nothing.
struct NullDirective : Directive {
	
	// See protocol.
	init(from parser: inout Parser) throws {
		TODO.unimplemented
	}
	
	// See protocol.
	func execute(on preprocessor: inout Preprocessor, in expansion: inout MacroExpansion) throws {}
	
}
