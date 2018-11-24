// DRAMASimulator © 2018 Constantino Tsarouhas

/// An address specified in assembly code.
struct AddressSpecification {
	
	/// The base address.
	///
	/// The base address is written as a signed value in assembly (since it supports negative offsets for indexation operations) but they're evaluated as unsigned values on the machine.
	var base: AddressWord
	
	/// The index to apply on the constant, or `nil` if no indexing is to be applied.
	var index: Index?
	struct Index {
		
		/// The register that contains the index.
		var indexRegister: Register
		
		/// The modification to perform on the index register before or after indexation, or `nil` if the index register is unaffected by indexing.
		var modification: Modification?
		enum Modification : Int {
			case preincrement	= 3
			case postincrement	= 4
			case predecrement	= 5
			case postdecrement	= 6
		}
		
	}
	
	/// Evaluates the effective address given the value of the index register.
	///
	/// The method is only meaningful for address specifications with indexation.
	func address(atIndex index: Word) -> AddressWord {
		return AddressWord(truncating: base.rawValue + index.rawValue)
	}
	
}

extension AddressSpecification {
	
	init(base: AddressWord, indexRegister: Register, mode: Int) {
		self.base = base
		self.index = Index(indexRegister: indexRegister, mode: mode)
	}
	
	var mode: Int {
		return index?.mode ?? 1
	}
	
}

extension AddressSpecification.Index {
	
	init?(indexRegister: Register, mode: Int) {
		if let modification = Modification(rawValue: mode) {
			self.init(indexRegister: indexRegister, modification: modification)
		} else if mode == 2 {
			self.init(indexRegister: indexRegister, modification: nil)
		} else {
			return nil
		}
	}
	
	var mode: Int {
		return modification?.rawValue ?? 2
	}
	
}
