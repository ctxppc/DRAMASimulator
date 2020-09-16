// DRAMASimulator © 2018–2020 Constantino Tsarouhas

/// An error that can be traced back to a range of source text.
protocol SourceError : Error {
	
	/// The range in the source text where the error originates.
	var sourceRange: SourceRange { get }
	
}
