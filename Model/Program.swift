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
	
	/// Adds given words to the data section, assigns them to given symbol, and returns the absolute address to the first element.
	mutating func addWords<Words : Collection>(_ words: Words, symbol: String) throws -> AddressWord where Words.Element == Word {
		
		guard !dataOffsetsBySymbol.keys.contains(symbol) else { throw SymbolError.duplicateSymbol }
		let address = AddressWord(rawValue: dataSection.endIndex + dataSectionBounds.lowerBound)!
		guard dataSectionBounds.contains(address.unsignedValue) else { throw AssemblyError.dataSectionOverflow }
		
		dataOffsetsBySymbol[symbol] = address
		dataSection.append(contentsOf: words)
		
		return address
		
	}
	
	/// Allocates a sequence of zero-initialised words of some size, assigns them to given symbol, and returns the absolute address to the first element.
	mutating func allocateWords(count: Int, symbol: String) throws -> AddressWord {
		return try addWords(repeatElement(.zero, count: count), symbol: symbol)
	}
	
	/// An error related to symbols.
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
		
		let textSection = try commands.map { c -> Word in
			
			let (command, opcode): (Command, Int) = {
				if let opcode = c.instruction.opcode {
					return (c, opcode)
				} else {
					let nativeCommand = c.nativeRepresentation
					guard let opcode = nativeCommand.instruction.opcode else { preconditionFailure("Native command has no opcode") }
					return (nativeCommand, opcode)
				}
			}()
			
			var word = CommandWord(.zero)
			word.opcode = opcode
			
			if let command = command as? ConditionAddressCommand, let condition = command.conditionOperand, let address = command.addressOperand {
				word.addressingMode = command.addressingMode.code(directAccessOnly: type(of: command).directAccessOnly)
				word.indexingMode = address.mode
				word.register = condition.code
				word.indexRegister = address.index?.indexRegister.rawValue ?? 0
				word.address = address.base.rawValue
			} else if let command = command as? RegisterAddressCommand, let register = command.registerOperand, let address = command.addressOperand {
				word.addressingMode = command.addressingMode.code(directAccessOnly: type(of: command).directAccessOnly)
				word.indexingMode = address.mode
				word.register = register.rawValue
				word.indexRegister = address.index?.indexRegister.rawValue ?? 0
				word.address = address.base.rawValue
			} else if let command = command as? AddressCommand, let address = command.addressOperand {
				word.addressingMode = command.addressingMode.code(directAccessOnly: type(of: command).directAccessOnly)
				word.indexingMode = address.mode
				word.indexRegister = address.index?.indexRegister.rawValue ?? 0
				word.address = address.base.rawValue
			} else if let command = command as? BinaryRegisterCommand, let primaryRegister = command.registerOperand, let secondaryRegister = command.secondaryRegisterOperand {
				word.addressingMode = AddressingMode.value.code(directAccessOnly: type(of: command).directAccessOnly)
				word.indexingMode = 2
				word.register = primaryRegister.rawValue
				word.indexRegister = secondaryRegister.rawValue
			} else if let command = command as? UnaryRegisterCommand, let register = command.registerOperand {
				word.addressingMode = AddressingMode.value.code(directAccessOnly: type(of: command).directAccessOnly)
				word.register = register.rawValue
			} else if command is NullaryCommand {
				// no arguments
			} else {
				throw AssemblyError.incompleteCommand
			}
			
			return word.base
			
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
	
	/// An error related to assembly such as memory management or command lowering.
	enum AssemblyError : Error {
		
		/// The text section and data section have overlapping bounds.
		case overlappingSections
		
		/// The text section does not fit in its bounds.
		case textSectionOverflow
		
		/// The data section does not fit in its bounds.
		case dataSectionOverflow
		
		/// The text or data section exceeds the address space.
		case invalidBounds
		
		/// The program has an incompletely specified command.
		case incompleteCommand
		
	}
	
}
