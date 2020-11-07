// DRAMASimulator © 2020 Constantino Tsarouhas

import Foundation

/// A lexical unit for a register, e.g., `R3`.
struct RegisterLexicalUnit : LexicalUnit {
	
	// See protocol.
	static let pattern = try! NSRegularExpression(pattern: #"R(\d+)"#, options: .caseInsensitive)
	
	// See protocol.
	init?(captures: [Substring], sourceRange: SourceRange) {
		guard let digit = Int(captures[1]), let register = Register(rawValue: digit) else { return nil }
		self.register = register
		self.sourceRange = sourceRange
	}
	
	/// The register.
	let register: Register
	
	// See protocol.
	let sourceRange: SourceRange
	
}
