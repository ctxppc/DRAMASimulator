// DRAMASimulator © 2018–2020 Constantino Tsarouhas

import Foundation

/// A statement initialising an array of words in memory.
///
/// Groups: array length (opt.), comma-separated literals (opt.)
struct ArrayStatement : Statement {
	
	// See protocol.
	static let regularExpression = NSRegularExpression(
		.alternatives(atomise: false,
			.atom(.arrayLengthPattern),
			.group(.literalConstantPattern, .atom(.elementSeparator, .literalConstantPattern), "*")
		)
	)
	
	// See protocol.
	init(match: NSTextCheckingResult, in source: String) throws {
		fullSourceRange = match.range(in: source)
		if let range = match.range(at: 1, in: source) {
			initialiser = .zeroArray(length: Int(source[range])!, sourceRange: range)
		} else {
			let range = match.range(at: 2, in: source)!
			let words = source[range].components(separatedBy: ",").map {
				Word(wrapping: Int($0.trimmingCharacters(in: .whitespaces))!)
			}
			initialiser = .literals(words: words, sourceRange: range)
		}
	}
	
	// See protocol.
	let fullSourceRange: SourceRange
	
	/// The array's initialiser.
	let initialiser: Initialiser
	enum Initialiser {
		
		/// The array is zero-initialised.
		///
		/// - Parameter length: The length of the zero-initialised array.
		/// - Parameter sourceRange: The range in the source where the length (as an integer) is written.
		case zeroArray(length: Int, sourceRange: SourceRange)
		
		/// The array is initialised with literals.
		///
		/// - Parameter words: The words the array is initialised with.
		/// - Parameter sourceRange: The range in the source where the (comma-separated) words are written.
		case literals(words: [Word], sourceRange: SourceRange)
		
	}
	
	// See protocol.
	var wordCount: Int {
		switch initialiser {
			case .zeroArray(length: let length, sourceRange: _):	return length
			case .literals(words: let words, sourceRange: _):		return words.count
		}
	}
	
	// See protocol.
	func words(addressesBySymbol: [String : Int]) -> AnyCollection<Word> {
		switch initialiser {
			case .zeroArray(length: let length, sourceRange: _):	return .init(repeatElement(.zero, count: length))
			case .literals(words: let words, sourceRange: _):		return .init(words)
		}
	}
	
}
