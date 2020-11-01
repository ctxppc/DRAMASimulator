// DRAMASimulator © 2018–2020 Constantino Tsarouhas

import DepthKit
import UIKit

/// A view controller that presents the contents of a document's source text.
final class ScriptEditingController : UIViewController {
	
	/// The presented script.
	var script: _Script = .init() {
		didSet {
			guard script.sourceText != oldValue.sourceText else { return }
			updatePresentedScript()
		}
	}
	
	/// The program counter.
	var programCounter: AddressWord = .zero {
		didSet { updateProgramCounterPresentation() }
	}
	
	/// Updates the script presentation.
	private func updatePresentedScript() {
		
		guard let textView = textView else { return }
		
		let formattedText = NSMutableAttributedString(string: script.sourceText, attributes: [
			.font:				UIFont(descriptor: UIFontDescriptor.preferredFontDescriptor(withTextStyle: .body).withDesign(.monospaced) !! "Expected font descriptor", size: 0),
			.foregroundColor:	UIColor.label,
			.paragraphStyle:	paragraphStyle
		])
		applyFormatting(on: formattedText)
		
		let oldSelectedRange = textView.selectedRange
		let oldText = textView.text ?? ""
		textView.attributedText = formattedText
		if let newSelectedRange = Range(oldSelectedRange, in: oldText)?.clamped(to: script.sourceText.startIndex..<script.sourceText.endIndex) {
			textView.selectedRange = NSRange(newSelectedRange, in: script.sourceText)
		}
		
		highlightedExecutingRange = nil
		updateProgramCounterPresentation()
		
	}
	
	private let paragraphStyle: NSParagraphStyle = {
		let s = NSParagraphStyle.default.mutableCopy() as! NSMutableParagraphStyle
		s.tabStops = []
		s.defaultTabInterval = 36
		return s.copy() as! NSParagraphStyle
	}()
	
	private func applyFormatting(on formattedText: NSMutableAttributedString) {
		
		formattedText.beginEditing()
		defer { formattedText.endEditing() }
		
		func addAttribute<V>(_ attribute: NSAttributedString.Key, value: V, range: SourceRange) {
			formattedText.addAttribute(attribute, value: value, range: NSRange(range, in: script.sourceText))
		}
		
		func mark(_ range: SourceRange?, _ attribute: NSAttributedString.Key = .foregroundColor, in colour: UIColor) {
			guard let range = range else { return }
			addAttribute(attribute, value: colour, range: range)
		}
		
		for unit in script.lexicalUnits {
			
			if let unit = unit as? _CommandStatement {
				mark(unit.instructionSourceRange, in: .mnemonic)
			}
			
			switch unit {
				
				case let unit as RegisterCommandStatement:
				mark(unit.primaryRegisterSourceRange.fullRange, in: .operand)
				mark(unit.secondaryRegisterSourceRange?.fullRange, in: .operand)
				
				case let unit as AddressCommandStatement:
				mark(unit.argument?.sourceRange, in: .operand)
				mark(unit.baseValueSourceRange, in: .operand)
				
				case let unit as _LabelLexicalUnit:
				addAttribute(.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: unit.sourceRange)
				mark(unit.sourceRange, in: .label)
				
				case let unit as _CommentLexicalUnit:
				mark(unit.sourceRange, in: .comment)
				
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
	
	private func updateProgramCounterPresentation() {
		
		guard let textView = textView, case .program(let program) = script.product else { return }
		
		let newRange: NSRange? = {
			guard let statement = program.statement(at: programCounter) else { return nil }
			return NSRange(statement.sourceRange, in: script.sourceText)
		}()
		guard highlightedExecutingRange != newRange else { return }
		
		if let oldRange = highlightedExecutingRange {
			textView.textStorage.removeAttribute(.backgroundColor, range: oldRange)
		}
		
		if let newRange = newRange {
			textView.textStorage.addAttribute(.backgroundColor, value: UIColor.executing, range: newRange)
		}
		
		highlightedExecutingRange = newRange
		
	}
	
	/// The string range highlighted as executing, or `nil` if no such highlighting applies to the current text view string.
	///
	/// This property is used to efficiently remove previous highlighting when updating the program counter presentation.
	private var highlightedExecutingRange: NSRange?
	
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
		
		let toolbar = UIToolbar()
		toolbar.items = [
			UIBarButtonItem(image: UIImage(systemName: "arrow.right.to.line.alt")!, style: .plain, target: self, action: #selector(indent))
		]
		toolbar.sizeToFit()
		textView.inputAccessoryView = toolbar
		
	}
	
	@objc dynamic func indent() {
		textView.insertText("\t")
	}
	
	override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
		super.traitCollectionDidChange(previousTraitCollection)
		updatePresentedScript()
	}
	
}

extension ScriptEditingController : UITextViewDelegate {
	
	func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText: String) -> Bool {
		guard replacementText == "\n", range.length == 0, let sRange = SourceRange(range, in: script.sourceText) else { return true }
		textView.insertText("\n\(script.sourceText.indentation(at: sRange.lowerBound))")
		return false
	}
	
	func textViewDidChange(_ textView: UITextView) {
		script = .init(from: textView.text)
		delegate?.sourceTextDidChange(on: self)
	}
	
	func textViewDidChangeSelection(_ textView: UITextView) {
		delegate?.selectedRangeDidChange(on: self)
	}
	
}

fileprivate extension String {
	
	/// Determines the range of the indentation used on the line containing the character at given position.
	func rangeOfIndentation(at index: String.Index) -> SourceRange {
		let match = indentationPattern.matches(in: self, options: [], range: NSRange(..<index, in: self)).last !! "Expected a match"
		return match.range(at: 1, in: self) !! "Expected group in match"
	}
	
	/// Determines the indentation used on the line containing the character at given position.
	func indentation(at index: String.Index) -> Substring {
		self[rangeOfIndentation(at: index)]
	}
	
}

let indentationPattern = try! NSRegularExpression(pattern: #"^([ \t]*)"#, options: .anchorsMatchLines)

protocol ScriptEditingControllerDelegate : class {
	
	/// Notifies the delegate that the source text has been modified.
	func sourceTextDidChange(on controller: ScriptEditingController)
	
	/// Notifies the delegate that the selected range has changed.
	func selectedRangeDidChange(on controller: ScriptEditingController)
	
}

fileprivate extension UIColor {
	static let executing = UIColor(named: "Executing") !! "Colour asset not found"
	static let mnemonic = #colorLiteral(red: 0, green: 0.3289999962, blue: 0.5749999881, alpha: 1)
	static let addressingMode = #colorLiteral(red: 0.5809999704, green: 0.1289999932, blue: 0.5749999881, alpha: 1)
	static let operand = #colorLiteral(red: 0, green: 0.5690000057, blue: 0.5749999881, alpha: 1)
	static let label = #colorLiteral(red: 0.5809999704, green: 0.08799999952, blue: 0.3190000057, alpha: 1)
	static let comment = #colorLiteral(red: 0.476000011, green: 0.476000011, blue: 0.476000011, alpha: 1)
}
