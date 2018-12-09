// DRAMASimulator © 2018 Constantino Tsarouhas

/// A directive that stops preprocessing and throws an error.
struct FailDirective : Directive {
	
	/// The message to present when this directive is processed.
	let message: String
	
	// See protocol.
	let fullSourceRange: SourceRange
	
	/// The range in the unprocessed source where the directive's instruction is written.
	let instructionRange: SourceRange
	
	/// The range in the unprocessed source where `message` is written.
	let messageRange: SourceRange
	
}
