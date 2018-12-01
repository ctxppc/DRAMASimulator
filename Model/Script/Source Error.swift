// DRAMASimulator © 2018 Constantino Tsarouhas

import Foundation

/// An error that can (conditionally) be traced back to a statement or lexical unit.
protocol StatementError : Error {
	
	/// The index of the statement in the script or program where the error originates, or `nil` if the location cannot be determined.
	var statementIndex: Int? { get }
	
}

/// An error that can be traced back to a range of source text.
protocol SourceError : Error {
	
	/// The range in the source text where the error originates.
	var sourceRange: SourceRange { get }
	
}

struct StatementSourceError : StatementError, SourceError, LocalizedError {
	
	/// Creates a statement source error with given underlying error and lexical units.
	///
	/// - Returns: `nil` if the location cannot be determined.
	init?(from error: StatementError, lexicalUnits: [LexicalUnit]) {
		guard let index = error.statementIndex else { return nil }
		underlyingError = error
		sourceRange = lexicalUnits[index].fullRange
	}
	
	/// The underlying error.
	let underlyingError: StatementError
	
	// See protocol.
	var statementIndex: Int? {
		return underlyingError.statementIndex
	}
	
	// See protocol.
	var localizedDescription: String {
		return underlyingError.localizedDescription
	}
	
	// See protocol.
	var errorDescription: String? {
		return (underlyingError as? LocalizedError)?.errorDescription ?? underlyingError.localizedDescription
	}
	
	// See protocol.
	let sourceRange: SourceRange
	
}
