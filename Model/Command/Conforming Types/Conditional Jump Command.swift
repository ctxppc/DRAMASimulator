// DRAMASimulator © 2018–2020 Constantino Tsarouhas

struct ConditionalJumpCommand : ConditionAddressCommand {
	
	// See protocol.
	static let supportedInstructions: Set = [Instruction.conditionalJump]
	
	// See protocol.
	static let directAccessOnly = true
	
	init(instruction: Instruction, addressingMode: AddressingMode?, condition: Condition, address: AddressSpecification) throws {
		self.condition = condition
		self.destination = address
		self.addressingMode = addressingMode ?? .direct
	}
	
	// See protocol.
	let instruction = Instruction.conditionalJump
	
	/// The condition required for the jump.
	let condition: Condition
	
	/// The jump destination.
	let destination: AddressSpecification
	
	/// The addressing mode for the destination.
	let addressingMode: AddressingMode
	
	// See protocol.
	func execute(on machine: inout Machine) {
		guard machine.conditionState.matches(condition) else { return }
		switch addressingMode {
			case .value:	fallthrough
			case .address:	fallthrough
			case .direct:	machine.programCounter = machine.evaluate(destination)
			case .indirect:	machine.programCounter = .init(truncating: machine[address: machine.evaluate(destination)])
		}
	}
	
	// See protocol.
	var conditionOperand: Condition? {
		return condition
	}
	
	// See protocol.
	var addressOperand: AddressSpecification? {
		return destination
	}
	
}
