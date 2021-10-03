// DRAMASimulator © 2020 Constantino Tsarouhas

import Foundation

/// A lexeme for an addressing mode, e.g., `.w`.
struct AddressingModeLexeme : Lexeme {
	
	// See protocol.
	static let pattern = try! NSRegularExpression(pattern: #"\.(\w+)"#, options: .caseInsensitive)
	
	// See protocol.
	init?(captures: [Substring], sourceRange: SourceRange) {
		guard let addressingMode = AddressingMode(rawValue: .init(captures[1])) else { return nil }
		self.addressingMode = addressingMode
		self.sourceRange = sourceRange
	}
	
	/// The register.
	let addressingMode: AddressingMode
	
	// See protocol.
	let sourceRange: SourceRange
	
}
