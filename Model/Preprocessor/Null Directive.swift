// DRAMASimulator © 2018 Constantino Tsarouhas

/// A directive that does nothing.
struct NullDirective : Directive {
	
	// See protocol.
	let fullSourceRange: SourceRange
	
	/// The range in the unprocessed source where the directive's instruction is written.
	let instructionRange: SourceRange
	
}
