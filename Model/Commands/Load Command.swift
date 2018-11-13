// DRAMASimulator © 2018 Constantino Tsarouhas

struct LoadCommand : NativeCommand {
	
	static let mnemonic = "HIA"
	static let code = 11
	
	static func addressingMode(withCode: Int) -> AddressingMode? {
		<#code#>
	}
	
	init(addressingMode: AddressingMode?, address: AddressSpecification) throws {
		<#code#>
	}
	
	init(addressingMode: AddressingMode?, register: Int, address: AddressSpecification) throws {
		<#code#>
	}
	
	init(addressingMode: AddressingMode?, condition: Condition, address: AddressSpecification) throws {
		<#code#>
	}
	
	func replaceLabels(_ addressesByLabel: [String : AddressWord]) throws {
		<#code#>
	}
	
	func execute(on machine: inout Machine) throws {
		<#code#>
	}
	
}
