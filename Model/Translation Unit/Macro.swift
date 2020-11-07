// DRAMASimulator © 2018–2020 Constantino Tsarouhas

import Foundation

/// A function-like template that can be invoked from source text, optionally from within another macro, and that expands in place.
struct Macro {
	
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
	
	/// The range in the unprocessed source where the macro is written.
	let fullSourceRange: SourceRange
	
	/// The range in the unprocessed source where the name is written.
	let nameSourceRange: SourceRange
	
	/// The range in the unprocessed source where the comma-separated parameters are written, or `nil` if the macro doesn't have parameters.
	let parametersSourceRange: SourceRange?
	
	/// The range of the body, including leading and trailing whitespace.
	let bodySourceRange: SourceRange
	
}
