// DRAMASimulator © 2020 Constantino Tsarouhas

import Foundation

/// A lexeme for a condition, e.g., `KLG`.
struct ConditionLexeme : Lexeme {
	
	// See protocol.
	static let pattern = try! NSRegularExpression(pattern: #"\w+"#)
	
	// See protocol.
	init?(captures: [Substring], sourceRange: SourceRange) {
		let rawValue = String(captures[0])
		guard let condition = Condition(rawValue: rawValue) ?? Condition(rawComparisonValue: rawValue) else { return nil }
		self.condition = condition
		self.sourceRange = sourceRange
	}
	
	/// The condition.
	let condition: Condition
	
	// See protocol.
	let sourceRange: SourceRange
	
}
