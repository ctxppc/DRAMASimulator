// DRAMASimulator © 2018–2020 Constantino Tsarouhas

import UIKit

/// A view controller that presents the contents of a document's source text.
final class ScriptEditingController : UIViewController {
	
	/// The presented script.
	var script: Script = .init() {
		didSet { updatePresentedScript() }
	}
	
	/// The base attributes for presenting source text.
	private static let baseAttributes = [
		NSAttributedString.Key.font:	UIFont.monospacedSystemFont(ofSize: 18, weight: .regular),
		.foregroundColor:				UIColor.label
	]
	
	private func updatePresentedScript() {
		
		guard let textView = textView else { return }
		
		if textView.text == script.sourceText {
			applyFormatting(on: textView.textStorage, removingPrevious: true)
		} else {
			
			let formattedText = NSMutableAttributedString(string: script.sourceText, attributes: Self.baseAttributes)
			applyFormatting(on: formattedText, removingPrevious: false)
			
			let oldSelectedRange = textView.selectedRange
			let oldText = textView.text ?? ""
			textView.attributedText = formattedText
			if let newSelectedRange = Range(oldSelectedRange, in: oldText)?.clamped(to: script.sourceText.startIndex..<script.sourceText.endIndex) {
				textView.selectedRange = NSRange(newSelectedRange, in: script.sourceText)
			}
			
		}
		
	}
	
	private func applyFormatting(on formattedText: NSMutableAttributedString, removingPrevious: Bool) {
		
		formattedText.beginEditing()
		defer { formattedText.endEditing() }
		
		if removingPrevious {
			formattedText.setAttributes(Self.baseAttributes, range: NSRange(location: 0, length: formattedText.length))
		}
		
		func addAttribute<V>(_ attribute: NSAttributedString.Key, value: V, range: SourceRange) {
			formattedText.addAttribute(attribute, value: value, range: NSRange(range, in: script.sourceText))
		}
		
		func mark(_ range: SourceRange?, _ attribute: NSAttributedString.Key = .foregroundColor, in colour: UIColor) {
			guard let range = range else { return }
			addAttribute(attribute, value: colour, range: range)
		}
		
		for unit in script.lexicalUnits {
			
			if let unit = unit as? CommandStatement {
				mark(unit.instructionSourceRange, in: .mnemonic)
			}
			
			switch unit {
				
				case let unit as RegisterCommandStatement:
				mark(unit.primaryRegisterSourceRange.fullRange, in: .operand)
				mark(unit.secondaryRegisterSourceRange?.fullRange, in: .operand)
				
				case let unit as AddressCommandStatement:
				mark(unit.argument?.sourceRange, in: .operand)
				mark(unit.baseAddressSourceRange, in: .operand)
				
				case let unit as LabelLexicalUnit:
				addAttribute(.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: unit.fullSourceRange)
				mark(unit.fullSourceRange, in: .label)
				
				case let unit as CommentLexicalUnit:
				mark(unit.fullSourceRange, in: .comment)
				
				default:
				break	// no need to handle every possible type of unit
				
			}
			
		}
		
		if case .sourceErrors(let errors) = script.product {
			for error in errors {
				addAttribute(.underlineStyle, value: ([.single, .patternDot, .byWord] as NSUnderlineStyle).rawValue, range: error.sourceRange)
				addAttribute(.underlineColor, value: UIColor.red, range: error.sourceRange)
			}
		}
		
	}
	
	/// The controller's delegate.
	weak var delegate: ScriptEditingControllerDelegate?
	
	/// The selected range, or `nil` if nothing is selected.
	var selectedRange: SourceRange? {
		textView.flatMap { SourceRange($0.selectedRange, in: $0.text) }
	}
	
	/// The text view presenting the script's text.
	@IBOutlet var textView: UITextView!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		updatePresentedScript()
	}
	
}

extension ScriptEditingController : UITextViewDelegate {
	
	func textViewDidChange(_ textView: UITextView) {
		script = .init(from: textView.text)
		delegate?.sourceTextDidChange(on: self)
	}
	
	func textViewDidChangeSelection(_ textView: UITextView) {
		delegate?.selectedRangeDidChange(on: self)
	}
	
}

protocol ScriptEditingControllerDelegate : class {
	
	/// Notifies the delegate that the source text has been modified.
	func sourceTextDidChange(on controller: ScriptEditingController)
	
	/// Notifies the delegate that the selected range has changed.
	func selectedRangeDidChange(on controller: ScriptEditingController)
	
}

fileprivate extension UIColor {
	static let mnemonic = #colorLiteral(red: 0, green: 0.3289999962, blue: 0.5749999881, alpha: 1)
	static let addressingMode = #colorLiteral(red: 0.5809999704, green: 0.1289999932, blue: 0.5749999881, alpha: 1)
	static let operand = #colorLiteral(red: 0, green: 0.5690000057, blue: 0.5749999881, alpha: 1)
	static let label = #colorLiteral(red: 0.5809999704, green: 0.08799999952, blue: 0.3190000057, alpha: 1)
	static let comment = #colorLiteral(red: 0.476000011, green: 0.476000011, blue: 0.476000011, alpha: 1)
}
