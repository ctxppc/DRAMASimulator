// DRAMASimulator © 2018–2020 Constantino Tsarouhas

import DepthKit
import UIKit

/// A view controller that presents the contents of a document's source text.
final class ScriptEditingController : UIViewController {
	
	/// The presented script.
	var script: Script = .init(from: "") {
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
		
		func applyAttribute<V>(_ attribute: NSAttributedString.Key, value: V, on unit: LexicalUnit) {
			formattedText.addAttribute(attribute, value: value, range: NSRange(unit.sourceRange, in: script.sourceText))
		}
		
		func applyAttribute<V, Units : Sequence>(_ attribute: NSAttributedString.Key, value: V, onAll units: Units) where Units.Element == LexicalUnit {
			for unit in units {
				applyAttribute(attribute, value: value, on: unit)
			}
		}
		
		func mark(unit: LexicalUnit, attribute: NSAttributedString.Key = .foregroundColor, colour: UIColor) {
			applyAttribute(attribute, value: colour, on: unit)
		}
		
		func mark<Units : Sequence>(units: Units, attribute: NSAttributedString.Key = .foregroundColor, colour: UIColor) where Units.Element == LexicalUnit {
			for unit in units {
				mark(unit: unit, attribute: attribute, colour: colour)
			}
		}
		
		for element in script.translationUnit.elements {
			switch element {
				
				case .statement(let statement as CommandStatement):
				mark(unit: statement.instructionLexicalUnit, colour: .command)
				mark(units: statement.argumentLexicalUnits, colour: .argument)
					
				case .statement(let statement as AllocationStatement):
				mark(unit: statement.directiveLexicalUnit, colour: .command)
				mark(unit: statement.sizeLexicalUnit, colour: .argument)
					
				case .statement(let statement as ValueStatement):
				mark(units: statement.lexicalUnits, colour: .argument)
					
				case .statement:
				break
					
				case .label(let label):
				mark(units: label.lexicalUnits, colour: .label)
				
				case .comment(let comment):
				mark(unit: comment, colour: .comment)
					 
				case .programTerminator(let terminator):
				mark(unit: terminator, colour: .comment)
					
				case .unrecognisedSource(let source):
				applyAttribute(.underlineStyle, value: ([.single, .patternDot, .byWord] as NSUnderlineStyle).rawValue, onAll: source.lexicalUnits)
				mark(units: source.lexicalUnits, attribute: .underlineColor, colour: .red)
				
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
		return SourceRange(match.range(at: 1), in: self) !! "Expected group in match"
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
	static let command = #colorLiteral(red: 0, green: 0.3289999962, blue: 0.5749999881, alpha: 1)
	static let addressingMode = #colorLiteral(red: 0.5809999704, green: 0.1289999932, blue: 0.5749999881, alpha: 1)
	static let argument = #colorLiteral(red: 0, green: 0.5690000057, blue: 0.5749999881, alpha: 1)
	static let label = #colorLiteral(red: 0.5809999704, green: 0.08799999952, blue: 0.3190000057, alpha: 1)
	static let comment = #colorLiteral(red: 0.476000011, green: 0.476000011, blue: 0.476000011, alpha: 1)
}
