// DRAMASimulator © 2020 Constantino Tsarouhas

import Foundation

/// A lexeme for an arithmetic operator.
struct ArithmeticOperatorLexeme : Lexeme {
	
	// See protocol.
	static let pattern = try! NSRegularExpression(pattern: #"[+\-*/]"#)
	
	// See protocol.
	init?(captures: [Substring], sourceRange: SourceRange) {
		guard let arithmeticOperator = ArithmeticOperator(rawValue: .init(captures[0])) else { return nil }
		self.arithmeticOperator = arithmeticOperator
		self.sourceRange = sourceRange
	}
	
	/// The arithmetic operator.
	let arithmeticOperator: ArithmeticOperator
	
	// See protocol.
	let sourceRange: SourceRange
	
}
