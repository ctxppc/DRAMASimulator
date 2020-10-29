// DRAMASimulator © 2020 Constantino Tsarouhas

import Foundation

/// A lexical unit for an addressing, e.g., `.w`.
struct AddressingModeLexicalUnit : LexicalUnit {
	
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
	var sourceRange: SourceRange
	
}
