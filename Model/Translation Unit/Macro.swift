// DRAMASimulator © 2018–2020 Constantino Tsarouhas

import Foundation

/// A function-like template that can be invoked from source text, optionally from within another macro, and that expands in place.
struct Macro : Directive {
	
	// See protocol.
	init(from parser: inout Parser) throws {
		TODO.unimplemented
	}
	
	/// The macro's name.
	let name: Substring
	
	/// The macro's parameters.
	let parameters: [String]
	
	/// The macro's (unprocessed) body.
	let body: Substring
	
	/// The directives of the macro, in source order.
	let directives: [Directive]
	
	/// A mapping from symbols to indices in the `directives` array.
	let directiveIndicesBySymbol: [String : Int]
	
}
