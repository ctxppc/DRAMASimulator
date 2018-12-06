// DRAMASimulator © 2018 Constantino Tsarouhas

import Foundation

/// A substring of a source text encoding a statement, comment, or label.
///
/// Lexical units are usually instantiated by scripts.
protocol LexicalUnit {
	
	/// The range in the source where the (whole) lexical unit is written.
	var fullSourceRange: SourceRange { get }
	
}

typealias SourceRange = Range<String.Index>

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
		return subpatterns.joined(separator: "|")
	}
	
	static let reqSpace = "\\s+"
	static let optSpace = "\\s*"
	static let elementSeparator = "\(optSpace),\(optSpace)"
	
	static let mnemonicPattern = "([A-Z]{3})"
	static let addressingModePattern = "\\.(w|a|d|i)"
	static let addressCommandMnemnonicPattern = "\(mnemonicPattern)(?:\(addressingModePattern))?"
	
	static let registerPattern = "(R([0-9]))"
	static let conditionPattern = "([A-Z]{2,4})"
	
	static let addressPattern = "(\(baseAddressPattern))(?:\(indexPattern))?"
	static let baseAddressPattern = "\(addressTermPattern)(?:\(optSpace)\\+\(optSpace)\(addressTermPattern))*"
	static let addressTermPattern = "(?:\(symbolPattern)|-?[0-9]+)"
	static let indexPattern = "\\(\(optIndexModifier)\(registerPattern)\(optIndexModifier)\\)"
	static let optIndexModifier = "(\\+|\\-)?"
	
	static let literalConstantPattern = "-?[0-9]{1,10}"
	static let arrayLengthPattern = "RESGR ([0-9]{1,4})"
	static let symbolPattern = "[a-z_][a-z0-9_]*"
	
}
