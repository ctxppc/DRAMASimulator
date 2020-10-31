// DRAMASimulator © 2020 Constantino Tsarouhas

import Foundation

/// A lexical unit for a condition, e.g., `KLG`.
struct ConditionLexicalUnit : LexicalUnit {
	
	// See protocol.
	static let pattern = try! NSRegularExpression(pattern: #"\w+"#)
	
	// See protocol.
	init?(captures: [Substring], sourceRange: SourceRange) {
		guard let condition = Condition(rawValue: .init(captures[0])) else { return nil }
		self.condition = condition
		self.sourceRange = sourceRange
	}
	
	/// The condition.
	let condition: Condition
	
	// See protocol.
	let sourceRange: SourceRange
	
}
