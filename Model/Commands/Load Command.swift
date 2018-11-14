// DRAMASimulator © 2018 Constantino Tsarouhas

struct LoadCommand : BinaryRegisterCommand, RegisterAddressCommand {
	
	// See protocol.
	static let supportedInstructions: Set = [Instruction.load]
	
	// See protocol.
	init(instruction: Instruction, primaryRegister: Register, secondaryRegister: Register) throws {
		source = .register(secondaryRegister)
		destination = primaryRegister
	}
	
	// See protocol.
	init(instruction: Instruction, addressingMode: AddressingMode?, register: Register, address: AddressSpecification) throws {
		source = .memory(address: address, mode: addressingMode ?? .direct)
		destination = register
	}
	
	// See protocol.
	let instruction = Instruction.load
	
	/// The register or memory address being loaded from.
	let source: Source
	enum Source {
		case register(Register)
		case memory(address: AddressSpecification, mode: AddressingMode)
	}
	
	/// The register being loaded into.
	let destination: Register
	
	// See protocol.
	func execute(on machine: inout Machine) throws {
		// TODO
	}
	
}
