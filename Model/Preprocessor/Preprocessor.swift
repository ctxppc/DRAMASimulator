// DRAMASimulator © 2018–2020 Constantino Tsarouhas

import Foundation

/// A value that transforms an unprocessed source into a processed source.
struct Preprocessor {
	
	/// Initialises and runs a preprocessor on given source text.
	init(from text: String) throws {
		TODO.unimplemented
	}
	
	/// The source text that is the input to the preprocessor.
	let input: String
	
	/// The range in the input text that has been processed.
	var processedRange: SourceRange {
		return input.startIndex..<indexOfFirstUnprocessedCharacter
	}
	
	/// The range in the input text that remains to be processed.
	var remainingRange: SourceRange {
		return indexOfFirstUnprocessedCharacter..<input.endIndex
	}
	
	/// The source text that is the output from the preprocessor.
	var output: String {
		return substitutions
			.sorted(by: { $0.range.lowerBound < $1.range.lowerBound })
			.reduce(into: (output: "", indexOfNextInputCharacter: "".startIndex)) { state, substitution in
				state.output.append(contentsOf: input[state.indexOfNextInputCharacter..<substitution.range.lowerBound])
				state.output.append(substitution.newText)
				state.indexOfNextInputCharacter = substitution.range.upperBound
			}.output
	}
	
	/// The substitutions performed by the preprocessor.
	private(set) var substitutions: [Substitution]
	struct Substitution {
		
		/// The range of unprocessed source text being replaced.
		let range: SourceRange
		
		/// The new text replacing the unprocessed substring.
		let newText: String
		
	}
	
	/// Adds the unprocessed source text between the first unprocessed character and a given upper bound (not inclusive) to the preprocessor's output.
	mutating func addPreservedSubstring(upTo upperBound: String.Index) {
		precondition((indexOfFirstUnprocessedCharacter...input.endIndex).contains(upperBound), "Upper bound not in unprocessed range")
		indexOfFirstUnprocessedCharacter = upperBound
	}
	
	/// Adds given text to the preprocessor's output and marks it as replacing the unprocessed source text between the first unprocessed character and a given upper bound (not inclusive).
	mutating func addSubstitution(upTo upperBound: String.Index, newText: String) {
		precondition((indexOfFirstUnprocessedCharacter...input.endIndex).contains(upperBound), "Upper bound not in unprocessed range")
		substitutions.append(.init(range: indexOfFirstUnprocessedCharacter..<upperBound, newText: newText))
		indexOfFirstUnprocessedCharacter = upperBound
	}
	
	/// The index of the first unprocessed character in the unprocessed source text.
	private var indexOfFirstUnprocessedCharacter: String.Index
	
	/// The macros defined in the source.
	let macros: [Macro]
	
	/// The macro invocations in the body of the source (outside of any macro body), in source order.
	let macroInvocations: [InvocationDirective]
	
}
