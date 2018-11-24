// DRAMASimulator © 2018 Constantino Tsarouhas

/// An error that can be associated with a line of source text.
protocol SourceError : Error {
	
	/// The line index in the source text where the error occurs.
	var lineIndex: Int { get }
	
}
