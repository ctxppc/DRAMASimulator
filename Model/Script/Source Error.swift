// DRAMASimulator © 2018 Constantino Tsarouhas

/// An error that is associated with a part of a source text.
struct SourceError : Error {
	
	/// The error.
	var underlyingError: Error
	
	/// The range of the erroneous source.
	var range: Range<String.Index>
	
}
