// DRAMASimulator © 2018–2020 Constantino Tsarouhas

import Foundation

/// A statement that contains a command.
protocol _CommandStatement : _Statement {
	
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

extension _CommandStatement {
	
	var wordCount: Int { 1 }
	
	func words(addressesBySymbol: [String : Int]) throws -> AnyCollection<MachineWord> {
		.init(CollectionOfOne(CommandWord(try command(addressesBySymbol: addressesBySymbol)).base))
	}
	
	@available(*, deprecated)
	var instructionSourceRange: SourceRange {
		sourceRange
	}
	
}
