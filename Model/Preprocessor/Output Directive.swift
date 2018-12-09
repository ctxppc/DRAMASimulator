// DRAMASimulator © 2018 Constantino Tsarouhas

import Foundation

/// A directive that outputs source.
struct OutputDirective : Directive {
	
	/// The source to process and output.
	let unprocessedOutputSource: String
	
	/// A mapping from ranges in the unprocessed source to expressions.
	///
	/// - Invariant: Every range `r` in `expressionsByRanges.keys` is fully contained within `self.unprocessedOutputSource`.
	let expressionsByRanges: [SourceRange : NSExpression]
	
	// See protocol.
	let fullSourceRange: SourceRange
	
	/// The range in the unprocessed source where `unprocessedOutputSource` is written.
	let unprocessedOutputSourceRange: SourceRange
	
	/// Returns the processed output.
	///
	/// - Parameter valuesBySymbol: A mapping of symbols to values in the context the directive is being processed in.
	///
	/// - Returns: The processed output.
	func output(valuesBySymbol: [String : Int]) throws -> String {
		fatalError("Unimplemented")	// TODO
	}
	
}
