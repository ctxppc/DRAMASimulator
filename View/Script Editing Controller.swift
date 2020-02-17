// DRAMASimulator © 2018 Constantino Tsarouhas

import UIKit

/// A view controller that presents the contents of a document's source text.
final class ScriptEditingController : UIViewController {
	
	/// The presented script.
	var script: Script = .init() {
		didSet { updatePresentedScript() }
	}
	
	/// The base attributes for presenting source text.
	private static let baseAttributes = [NSAttributedString.Key.font: UIFont(name: "Menlo", size: 18)!, .foregroundColor: UIColor.label]
	
	private func updatePresentedScript() {
		
		guard let errorBar = errorBar, let errorLabel = errorLabel, let textView = textView else { return }
		
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
		
		let errors: [Error]
		switch script.program {
			case .program:							errors = []
			case .sourceErrors(let sourceErrors):	errors = sourceErrors
			case .programError(let error):			errors = [error]
		}
		
		if errors.isEmpty {
			errorBar.isHidden = true
			errorLabel.text = "Geen fouten"
		} else {
			errorBar.isHidden = false
			errorLabel.text = errors.map { error in
				"⚠️ \((error as? LocalizedError)?.errorDescription ?? error.localizedDescription)"
			}.joined(separator: "\n")
		}
		
	}
	
	private func applyFormatting(on formattedText: NSMutableAttributedString, removingPrevious: Bool) {
		
		formattedText.beginEditing()
		defer { formattedText.endEditing() }
		
		if removingPrevious {
			formattedText.setAttributes(Self.baseAttributes, range: NSRange(location: 0, length: formattedText.length))
		}
		
		func mark(_ range: SourceRange?, _ attribute: NSAttributedString.Key = .foregroundColor, in colour: UIColor) {
			guard let range = range else { return }
			formattedText.addAttribute(attribute, value: colour, range: NSRange(range, in: script.sourceText))
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
				formattedText.addAttribute(.underlineStyle, value: NSUnderlineStyle.double.rawValue, range: NSRange(unit.fullSourceRange, in: script.sourceText))
				mark(unit.fullSourceRange, in: .label)
				
				case let unit as CommentLexicalUnit:
				mark(unit.fullSourceRange, in: .comment)
				
				default:
				break	// no need to handle every possible type of unit
				
			}
			
		}
		
		if case .sourceErrors(let errors) = script.program {
			for error in errors {
				mark(error.sourceRange, .backgroundColor, in: #colorLiteral(red: 0.9179999828, green: 0.8460000157, blue: 0.8140000105, alpha: 1))
			}
		}
		
	}
	
	/// The controller's delegate.
	weak var delegate: ScriptEditingControllerDelegate?
	
	/// The selected range, or `nil` if nothing is selected.
	var selectedRange: SourceRange? {
		guard let textView = textView else { return nil }
		return SourceRange(textView.selectedRange, in: textView.text)
	}
	
	/// The text view presenting the script's text.
	@IBOutlet var textView: UITextView!
	
	/// The arranged view hosting the error label.
	@IBOutlet weak var errorBar: UIView!
	
	/// The label presenting a description of the script's source errors.
	@IBOutlet weak var errorLabel: UILabel!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		updatePresentedScript()
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		keyboardWillChangeFrameObserver = NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillChangeFrameNotification, object: nil, queue: nil) { [weak self] notification in
			
			guard let controller = self else { return }
			
			let keyboardFrame = notification.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! CGRect
			let viewFrame = controller.view.convert(controller.view.bounds, to: controller.view.window)
			let bottomInset = viewFrame.maxY - keyboardFrame.minY
			
			controller.textView.contentInset.bottom = bottomInset
			controller.textView.horizontalScrollIndicatorInsets.bottom = bottomInset
			controller.textView.verticalScrollIndicatorInsets.bottom = bottomInset
			
		}
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		keyboardWillChangeFrameObserver.flatMap(NotificationCenter.default.removeObserver)
	}
	
	private var keyboardWillChangeFrameObserver: Any?
	
}

extension ScriptEditingController : UITextViewDelegate {
	
	func textViewDidChange(_ textView: UITextView) {
		script.sourceText = textView.text
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
