// DRAMASimulator © 2018 Constantino Tsarouhas

import Foundation

/// A statement that contains a command.
protocol CommandStatement : Statement {
	
	/// The instruction represented by this command.
	var instruction: Instruction { get }
	
	/// The range in the source where the instruction is written.
	var instructionSourceRange: SourceRange { get }
	
	/// Returns the command encoded in the statement.
	///
	/// - Parameter addressesBySymbol: A mapping of symbols to absolute addresses.
	///
	/// - Throws: An error if an undefined symbol is used.
	///
	/// - Returns: A command.
	func command(addressesBySymbol: [String : Int]) throws -> Command
	
}

extension CommandStatement {
	
	var wordCount: Int {
		return 1
	}
	
	func words(addressesBySymbol: [String : Int]) throws -> AnyCollection<Word> {
		return .init(CollectionOfOne(CommandWord(try command(addressesBySymbol: addressesBySymbol)).base))
	}
	
}

enum CommandStatementError : LocalizedError {
	
	/// The command has an incorrect format, e.g., register operands for an address–condition command type.
	case incorrectFormat(instruction: Instruction)
	
	var errorDescription: String? {
		switch self {
			case .incorrectFormat(instruction: let i):	return "\(i.rawValue)-bevel met onjuiste formaat"
		}
	}
	
}