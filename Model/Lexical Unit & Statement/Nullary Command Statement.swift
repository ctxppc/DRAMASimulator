// DRAMASimulator © 2018 Constantino Tsarouhas

import Foundation

/// A statement that contains a nullary command.
///
/// Groups: mnemonic
struct NullaryCommandStatement : CommandStatement {
	
	// See protocol.
	static let regularExpression = NSRegularExpression(.mnemonicPattern)
	
	// See protocol.
	init(match: NSTextCheckingResult, in source: String) throws {
		fullSourceRange = match.range(in: source)
		instructionSourceRange = match.range(at: 1, in: source)!
		instruction = try Instruction(in: source, at: instructionSourceRange)
	}
	
	// See protocol.
	let instruction: Instruction
	
	// See protocol.
	let fullSourceRange: SourceRange
	
	// See protocol.
	let instructionSourceRange: SourceRange
	
	// See protocol.
	func command(addressesBySymbol: [String : Int]) throws -> Command {
		guard let type = instruction.commandType as? NullaryCommand.Type else { throw CommandStatementError.incorrectArgumentFormat(instruction: instruction) }
		return try type.init(instruction: instruction)
	}
	
}
