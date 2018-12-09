// DRAMASimulator © 2018 Constantino Tsarouhas

import Foundation

extension NSRegularExpression {
	convenience init(anchored: Bool = true, _ subpatterns: String...) {
		let pattern = subpatterns.joined()
		try! self.init(pattern: anchored ? "^\(pattern)$" : pattern, options: .caseInsensitive)
	}
}

// Convenience methods for extracting captures.
extension NSTextCheckingResult {
	
	func range(at group: Int, in source: String) -> SourceRange? {
		let range = self.range(at: group)
		guard range.location != NSNotFound else { return nil }
		return SourceRange(range, in: source)
	}
	
	func range(in source: String) -> SourceRange {
		return SourceRange(range, in: source)!
	}
	
}

// Convenience constants and functions for building regular expressions.
extension String {
	
	static func opt(_ subpatterns: String...) -> String {
		return "(?:\(subpatterns.joined()))?"
	}
	
	static func group(_ subpatterns: String...) -> String {
		return "(\(subpatterns.joined()))"
	}
	
	static func atom(_ subpatterns: String...) -> String {
		return "(?:\(subpatterns.joined()))"
	}
	
	static func alternatives(atomise: Bool = true, _ subpatterns: String...) -> String {
		let subpatterns = atomise ? subpatterns.map { atom($0) } : subpatterns
		return atom(subpatterns.joined(separator: "|"))
	}
	
	static let reqSpace = "\\s+"
	static let optSpace = "\\s*"
	static let elementSeparator = "\(optSpace),\(optSpace)"
	
	static let mnemonicPattern = group("[A-Z]{3}")
	static let addressingModePattern = "\\." + group("w|a|d|i")
	static let addressCommandMnemnonicPattern = mnemonicPattern + opt(addressingModePattern)
	
	static let registerPattern = group("R", group("[0-9]"))
	static let conditionPattern = group("[A-Z]{2,4}")
	
	static let addressPattern = group(baseAddressPattern) + opt(indexPattern)
	static let baseAddressPattern = "\(addressTermPattern)(?:\(optSpace)\(addressOperation)\(optSpace)\(addressTermPattern))*"
	static let addressTermPattern = "(?:\(symbolPattern)|-?[0-9]+)"
	static let addressOperation = alternatives(atomise: false, "\\+", "-")
	static let indexPattern = "\\(\(indexOperatorPattern)\(registerPattern)\(indexOperatorPattern)\\)"
	static let indexOperatorPattern = "(\\+|-)?"
	
	static let literalConstantPattern = "-?[0-9]{1,10}"
	static let arrayLengthPattern = "RESGR\(reqSpace)([0-9]{1,4})"
	static let symbolPattern = "[a-z_][a-z0-9_]*"
	
	static let macroPattern = "MACRO\(reqSpace)\(macroSignaturePattern)(.*?)\(reqSpace)MCREINDE"
	static let macroSignaturePattern = group(symbolPattern) + opt(optHorizontalSpace + macroParametersPattern)
	static let macroParametersPattern = group(atom(symbolPattern, optHorizontalSpace, ",", optHorizontalSpace) + "*" + symbolPattern)
	static let optHorizontalSpace = "[\\t ]*"
	
}
