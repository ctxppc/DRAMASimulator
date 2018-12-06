// DRAMASimulator © 2018 Constantino Tsarouhas

struct Macro {
	
	/// The macro's name.
	let name: String
	
	/// The macro's parameters.
	let parameters: [String]
	
	/// A mapping from symbols to indices in the `directives` array.
	let directiveIndicesBySymbol: [String : Int]
	
	/// The directives of the macro.
	let directives: [Directive]
	
	/// The range in the unprocessed source where the name is written.
	let nameRange: SourceRange
	
	/// The ranges in the unprocessed source where the parameters are written.
	let parameterRanges: [SourceRange]
	
	/// The range of the body, including leading and trailing whitespace.
	let bodyRange: SourceRange
	
}
