// DRAMASimulator © 2018 Constantino Tsarouhas

import Foundation

struct Macro {
	
	/// A regular expression matching macros.
	static let regularExpression = NSRegularExpression(anchored: false, .macroPattern)
	
	/// Creates a macro from given regular expression match.
	///
	/// Groups: name, comma-separated parameter names (opt.), body without leading and trailing whitespace
	init(match: NSTextCheckingResult, in source: String) {
		
		fullSourceRange = match.range(in: source)
		
		nameSourceRange = match.range(at: 1, in: source)!
		name = source[nameSourceRange]
		
		bodySourceRange = match.range(at: 3, in: source)!
		body = source[bodySourceRange]
		
		parametersSourceRange = match.range(at: 2, in: source)
		parameters = parametersSourceRange.flatMap { range in
			source[range].components(separatedBy: ",")
		} ?? []
		
	}
	
	/// The macro's name.
	let name: Substring
	
	/// The macro's parameters.
	let parameters: [String]
	
	/// The macro's (unprocessed) body.
	let body: Substring
	
	/// A mapping from symbols to indices in the `directives` array.
	let directiveIndicesBySymbol: [String : Int]
	
	/// The directives of the macro.
	let directives: [Directive]
	
	/// The range in the unprocessed source where the macro is written.
	let fullSourceRange: SourceRange
	
	/// The range in the unprocessed source where the name is written.
	let nameSourceRange: SourceRange
	
	/// The range in the unprocessed source where the comma-separated parameters are written, or `nil` if the macro doesn't have parameters.
	let parametersSourceRange: SourceRange?
	
	/// The range of the body, including leading and trailing whitespace.
	let bodySourceRange: SourceRange
	
}
