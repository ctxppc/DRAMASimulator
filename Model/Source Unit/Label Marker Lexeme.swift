// DRAMASimulator © 2020 Constantino Tsarouhas

import Foundation

/// A marker lexeme for a label, i.e.., `:`.
struct LabelMarkerLexeme : Lexeme {
	
	// See protocol.
	static let pattern = try! NSRegularExpression(pattern: #":"#)
	
	// See protocol.
	init(captures: [Substring], sourceRange: SourceRange) {
		self.sourceRange = sourceRange
	}
	
	// See protocol.
	let sourceRange: SourceRange
	
}
