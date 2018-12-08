// DRAMASimulator © 2018 Constantino Tsarouhas

import Foundation

/// A statement that contains an address, register–address, or condition-address command.
///
/// Groups: mnemonic, addressing mode (opt.), register (opt.), reg. # (opt.), condition (opt.), base address, pre-index modifier (opt.), index register (opt.), index register # (opt.), post-index modifier (opt.)
struct AddressCommandStatement : CommandStatement {
	
	// See protocol.
	static let regularExpression = NSRegularExpression(
		.addressCommandMnemnonicPattern,
		.reqSpace,
		.opt(.alternatives(atomise: false, .registerPattern, .conditionPattern), .elementSeparator),
		.addressPattern
	)
	
	// See protocol.
	init(match: NSTextCheckingResult, in source: String) throws {
		
		fullSourceRange = match.range(in: source)
		instructionSourceRange = match.range(at: 1, in: source)!
		instruction = try Instruction(in: source, at: instructionSourceRange)
		addressingModeSourceRange = match.range(at: 2, in: source)
		addressingMode = try addressingModeSourceRange.flatMap { try AddressingMode(in: source, at: $0) }
		baseAddressSourceRange = match.range(at: 6, in: source)!
		baseAddress = try .init(from: source[baseAddressSourceRange])
		indexSourceRange = IndexSourceRange(match: match, firstGroup: 7, source: source)
		
		if let range = RegisterSourceRange(match: match, firstGroup: 3, source: source) {
			argument = .register(Register(rawValue: Int(source[range.numberRange])!)!, sourceRange: range)
		} else if let range = match.range(at: 5, in: source) {
			let rawValue = source[range].uppercased()
			guard let condition = Condition(rawValue: rawValue) ?? Condition(rawComparisonValue: rawValue) else { throw ParsingError.unknownCondition(rawValue) }
			argument = .condition(condition, sourceRange: range)
		} else {
			argument = nil
		}
		
		if let range = indexSourceRange {
			let modification: AddressSpecification.Index.Modification?
			switch (range.preindexationOperationRange.flatMap({ source[$0] }), range.postindexationOperationRange.flatMap({ source[$0] })) {
				case (nil, nil):	modification = nil
				case ("+", nil):	modification = .preincrement
				case ("-", nil):	modification = .predecrement
				case (nil, "+"):	modification = .postincrement
				case (nil, "-"):	modification = .postdecrement
				default:			throw ParsingError.doubleIndexModification
			}
			index = .init(indexRegister: Register(rawValue: Int(source[range.indexRegisterRange.numberRange])!)!, modification: modification)
		} else {
			index = nil
		}
		
	}
	
	// See protocol.
	let instruction: Instruction
	
	/// The addressing mode, or `nil` if not specified.
	let addressingMode: AddressingMode?
	
	/// The address.
	let baseAddress: SymbolicAddress
	
	/// The index, or `nil` if not specified.
	let index: AddressSpecification.Index?
	
	// See protocol.
	let fullSourceRange: SourceRange
	
	// See protocol.
	let instructionSourceRange: SourceRange
	
	/// The range in the source where the addressing mode is written, excluding the mnemonic–addressing mode separator (the full stop character); or `nil` if no addressing mode is written.
	let addressingModeSourceRange: SourceRange?
	
	/// The non-address argument of the address command, or `nil` if it only has an address.
	let argument: Argument?
	enum Argument {
		
		/// A register argument.
		case register(Register, sourceRange: RegisterSourceRange)
		
		/// A condition argument.
		case condition(Condition, sourceRange: SourceRange)
		
		/// The source range of the (whole) argument.
		var sourceRange: SourceRange {
			switch self {
				case .register(_, sourceRange: let range):	return range.fullRange
				case .condition(_, sourceRange: let range):	return range
			}
		}
		
	}
	
	/// The range in the source where the base address is written.
	let baseAddressSourceRange: SourceRange
	
	/// The range in the source where the index is written, or `nil` if no index is written.
	let indexSourceRange: IndexSourceRange?
	
	/// An error whilst parsing an address command statement.
	enum ParsingError : LocalizedError {
		
		/// Both a pre- and post-indexation modification are specified.
		case doubleIndexModification
		
		/// An unknown condition is specified.
		case unknownCondition(String)
		
		// See protocol.
		var errorDescription: String? {
			switch self {
				case .doubleIndexModification:			return "Dubbele indexatie"
				case .unknownCondition(let condition):	return "Onbekende voorwaarde “\(condition)”"
			}
		}
		
	}
	
	// See protocol.
	func command(addressesBySymbol: [String : Int]) throws -> Command {
		let addressSpecification = AddressSpecification(base: .init(wrapping: try baseAddress.effectiveAddress(addressesBySymbol: addressesBySymbol)), index: index)
		switch argument {
			
			case .register(let register, sourceRange: _)?:
			guard let type = instruction.commandType as? RegisterAddressCommand.Type else { throw CommandStatementError.incorrectArgumentFormat(instruction: instruction) }
			return try type.init(instruction: instruction, addressingMode: addressingMode, register: register, address: addressSpecification)
			
			case .condition(let condition, sourceRange: _)?:
			guard let type = instruction.commandType as? ConditionAddressCommand.Type else { throw CommandStatementError.incorrectArgumentFormat(instruction: instruction) }
			return try type.init(instruction: instruction, addressingMode: addressingMode, condition: condition, address: addressSpecification)
			
			case nil:
			guard let type = instruction.commandType as? AddressCommand.Type else { throw CommandStatementError.incorrectArgumentFormat(instruction: instruction) }
			return try type.init(instruction: instruction, addressingMode: addressingMode, address: addressSpecification)
			
		}
	}
	
}

struct IndexSourceRange {
	
	fileprivate init?(match: NSTextCheckingResult, firstGroup group: Int, source: String) {
		
		guard let indexRegisterRange = RegisterSourceRange(match: match, firstGroup: group + 1, source: source) else { return nil }
		let preindexationOperationRange = match.range(at: group)
		let postindexationOperationRange = match.range(at: group + 3)
		
		self.indexRegisterRange = indexRegisterRange
		self.preindexationOperationRange = preindexationOperationRange.location != NSNotFound ? SourceRange(preindexationOperationRange, in: source)! : nil
		self.postindexationOperationRange = postindexationOperationRange.location != NSNotFound ? SourceRange(postindexationOperationRange, in: source)! : nil
		
	}
	
	/// The source range of the index register.
	let indexRegisterRange: RegisterSourceRange
	
	/// The source range of the pre-indexation operation.
	let preindexationOperationRange: SourceRange?
	
	/// The source range of the post-indexation operation.
	let postindexationOperationRange: SourceRange?
	
}

