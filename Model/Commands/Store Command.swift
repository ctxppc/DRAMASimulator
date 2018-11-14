// DRAMASimulator © 2018 Constantino Tsarouhas

struct StoreCommand : RegisterAddressCommand {
	
	// See protocol.
	static let supportedInstructions: Set = [Instruction.store]
	
	// See protocol.
	init(instruction: Instruction, addressingMode mode: AddressingMode?, register: Register, address: AddressSpecification) throws {
		source = register
		destination = address
		addressingMode = mode ?? .direct
	}
	
	// See protocol.
	let instruction = Instruction.store
	
	/// The register whose value is being stored.
	let source: Register
	
	/// The memory address being stored into.
	let destination: AddressSpecification
	
	/// The addressing mode.
	let addressingMode: AddressingMode
	
	// See protocol.
	func execute(on machine: inout Machine) throws {
		// TODO
	}
	
}
