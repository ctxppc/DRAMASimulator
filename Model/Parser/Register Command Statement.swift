// DRAMASimulator © 2018–2020 Constantino Tsarouhas

import Foundation

/// A statement that contains a unary or binary register command.
///
/// Groups: mnemonic, primary register, reg. #, secondary register (opt.), reg. # (opt.)
struct RegisterCommandStatement : CommandStatement {
	
	// See protocol.
	static let regularExpression = NSRegularExpression(.mnemonicPattern, .reqSpace, .registerPattern, .opt(.elementSeparator, .registerPattern))
	
	// See protocol.
	init(match: NSTextCheckingResult, in source: String) throws {
		sourceRange = match.range(in: source)
		instructionSourceRange = match.range(at: 1, in: source)!
		instruction = try Instruction(in: source, at: instructionSourceRange)
		primaryRegisterSourceRange = RegisterSourceRange(match: match, firstGroup: 2, source: source)!
		primaryRegister = Register(rawValue: Int(source[primaryRegisterSourceRange.numberRange])!)!
		secondaryRegisterSourceRange = RegisterSourceRange(match: match, firstGroup: 4, source: source)
		secondaryRegister = secondaryRegisterSourceRange.flatMap { Register(rawValue: Int(source[$0.numberRange])!)! }
	}
	
	// See protocol.
	let instruction: Instruction
	
	/// The primary register
	let primaryRegister: Register
	
	/// The secondary register, or `nil` if not applicable.
	let secondaryRegister: Register?
	
	// See protocol.
	let sourceRange: SourceRange
	
	// See protocol.
	let instructionSourceRange: SourceRange
	
	/// The range in the source where the primary register is written.
	let primaryRegisterSourceRange: RegisterSourceRange
	
	/// The range in the source where the secondary register is written, or `nil` if no secondary register is written.
	let secondaryRegisterSourceRange: RegisterSourceRange?
	
	// See protocol.
	func command(addressesBySymbol: [String : Int]) throws -> Command {
		if let secondaryRegister = secondaryRegister {
			guard let type = instruction.commandType as? BinaryRegisterCommand.Type else { throw CommandStatementError.incorrectArgumentFormat(instruction: instruction) }
			return try type.init(instruction: instruction, primaryRegister: primaryRegister, secondaryRegister: secondaryRegister)
		} else {
			guard let type = instruction.commandType as? UnaryRegisterCommand.Type else { throw CommandStatementError.incorrectArgumentFormat(instruction: instruction) }
			return try type.init(instruction: instruction, register: primaryRegister)
		}
	}
	
}

/// A source range where a register is written.
struct RegisterSourceRange {
	
	init?(match: NSTextCheckingResult, firstGroup group: Int, source: String) {
		guard let numberRange = match.range(at: group + 1, in: source), let fullRange = match.range(at: group, in: source) else { return nil }
		self.numberRange = numberRange
		self.fullRange = fullRange
	}
	
	/// The range in the source where the register number is written, i.e., without the `R` specifier.
	let numberRange: SourceRange
	
	/// The range in the source where the register as an argument is written, i.e., including the `R` specifier.
	let fullRange: SourceRange
	
}
