// DRAMASimulator © 2018 Constantino Tsarouhas

/// A parsed script that can be readily converted into machine words.
struct Program {
	
	/// The bounds of the program text section.
	let textSectionBounds = 0..<200
	
	/// The commands.
	///
	/// Non-native commands are translated into their native representation before assembly.
	var commands: [Command]
	
	/// The bounds of the program data section.
	let dataSectionBounds = 200..<800
	
	/// The offsets inside the data section keyed by symbol name.
	private(set) var dataOffsetsBySymbol: [String : AddressWord] = [:]
	
	/// The memory section where globals can be added.
	private(set) var dataSection: [Word] = []
	
	/// Adds given words to the data section, assigns them with given symbol, and returns the absolute address to the first element.
	mutating func addWords<Words : Collection>(_ words: Words, symbol: String) throws -> AddressWord where Words.Element == Word {
		guard !dataOffsetsBySymbol.keys.contains(symbol) else { throw SymbolError.duplicateSymbol }
		let absoluteOffset = dataSection.endIndex + dataSectionBounds.lowerBound
		dataSection.append(contentsOf: words)
		return AddressWord(rawValue: absoluteOffset)!
	}
	
	mutating func allocateWords(count: Int, symbol: String) throws -> AddressWord {
		return try addWords(repeatElement(.zero, count: count), symbol: symbol)
	}
	
	
	enum SymbolError : Error {
		
		/// The symbol is already associated with an offset.
		case duplicateSymbol
		
	}
	
	/// Assembles the program into machine words, ready to be loaded into and executed by a machine.
	///
	/// - Postcondition: The resulting array has `AddressWord.upperUnsignedValue` words.
	func machineWords() throws -> [Word] {
		
		let addressSpace = Machine.emptyMemory.indices
		guard addressSpace.contains(textSectionBounds.lowerBound),
			addressSpace.contains(textSectionBounds.upperBound - 1),
			addressSpace.contains(dataSectionBounds.lowerBound),
			addressSpace.contains(dataSectionBounds.upperBound - 1)
			else { throw AssemblyError.invalidBounds }
		guard !textSectionBounds.overlaps(dataSectionBounds) else { throw AssemblyError.overlappingSections }
		
		guard dataSection.count < dataSectionBounds.count else { throw AssemblyError.dataSectionOverflow }
		let paddedDataSection = dataSection + repeatElement(.zero, count: dataSectionBounds.count - dataSection.count)
		
		let textSection = try commands.map { command -> Word in
			
			guard let opcode = command.instruction.opcode else { throw AssemblyError.nonnativeCommand }
			let addrMode: Int
			let indMode: Int
			let reg: Int
			let indReg: Int
			let addr: Int
			
			if let command = command as? ConditionAddressCommand, let condition = command.conditionOperand, let address = command.addressOperand {
				addrMode = command.addressingMode.code(directAccessOnly: type(of: command).directAccessOnly)
				indMode = address.mode
				reg = condition.code
				indReg = address.index?.indexRegister.rawValue ?? 0
				addr = address.base.rawValue
			} else if let command = command as? RegisterAddressCommand, let register = command.registerOperand, let address = command.addressOperand {
				addrMode = command.addressingMode.code(directAccessOnly: type(of: command).directAccessOnly)
				indMode = address.mode
				reg = register.rawValue
				indReg = address.index?.indexRegister.rawValue ?? 0
				addr = address.base.rawValue
			} else if let command = command as? AddressCommand, let address = command.addressOperand {
				addrMode = command.addressingMode.code(directAccessOnly: type(of: command).directAccessOnly)
				indMode = address.mode
				reg = 0
				indReg = address.index?.indexRegister.rawValue ?? 0
				addr = address.base.rawValue
			} else if let command = command as? BinaryRegisterCommand, let primaryRegister = command.registerOperand, let secondaryRegister = command.secondaryRegisterOperand {
				addrMode = AddressingMode.value.code(directAccessOnly: type(of: command).directAccessOnly)
				indMode = 2
				reg = primaryRegister.rawValue
				indReg = secondaryRegister.rawValue
				addr = 0
			} else if let command = command as? UnaryRegisterCommand, let register = command.registerOperand {
				addrMode = AddressingMode.value.code(directAccessOnly: type(of: command).directAccessOnly)
				indMode = 0
				reg = register.rawValue
				indReg = 0
				addr = 0
			} else if command is NullaryCommand {
				addrMode = 0
				indMode = 0
				reg = 0
				indReg = 0
				addr = 0
			} else {
				throw AssemblyError.incompleteCommand
			}
			
			let word = opcode	* 100_000_0000
				+ addrMode		* 1000_0000
				+ indMode		* 100_0000
				+ reg			* 10_0000
				+ indReg		* 1_0000
				+ addr
			
			return Word(rawValue: word)!
			
		}
		
		guard textSection.count < textSectionBounds.count else { throw AssemblyError.textSectionOverflow }
		let paddedTextSection = textSection + repeatElement(.zero, count: textSectionBounds.count - textSection.count)
		
		let memory: [Word]
		if textSectionBounds.lowerBound < dataSectionBounds.lowerBound {
			memory = repeatElement(.zero, count: textSectionBounds.lowerBound)
				+ paddedTextSection
				+ repeatElement(.zero, count: dataSectionBounds.lowerBound - textSectionBounds.upperBound)
				+ paddedDataSection
				+ repeatElement(.zero, count: addressSpace.upperBound - dataSectionBounds.upperBound)
		} else {
			memory = repeatElement(.zero, count: dataSectionBounds.lowerBound)
				+ paddedDataSection
				+ repeatElement(.zero, count: textSectionBounds.lowerBound - dataSectionBounds.upperBound)
				+ paddedTextSection
				+ repeatElement(.zero, count: addressSpace.upperBound - textSectionBounds.upperBound)
		}
		
		return memory
		
	}
	
	/// An error that occurs during assembly.
	enum AssemblyError : Error {
		
		/// The text section and data section have overlapping bounds.
		case overlappingSections
		
		/// The text section does not fit in its bounds.
		case textSectionOverflow
		
		/// The data section does not fit in its bounds.
		case dataSectionOverflow
		
		/// The text or data section exceeds the address space.
		case invalidBounds
		
		/// The program has a nonnative command. Nonnative commands are currently unsupported.
		case nonnativeCommand
		
		/// The program has an incompletely specified command.
		case incompleteCommand
		
	}
	
}
