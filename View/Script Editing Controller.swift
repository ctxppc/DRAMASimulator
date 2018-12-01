// DRAMASimulator © 2018 Constantino Tsarouhas

import UIKit

/// A view controller that presents the contents of a document's source text.
final class ScriptEditingController : UIViewController {
	
	/// The presented script.
	var script: Script = .init() {
		didSet { updatePresentedScript() }
	}
	
	/// The font for presenting source text.
	private static let sourceFont = UIFont(name: "Menlo", size: 18)!
	
	private func updatePresentedScript() {
		
		guard let errorBar = errorBar, let errorLabel = errorLabel, let textView = textView else { return }
		
		let formattedText = NSMutableAttributedString(string: script.sourceText, attributes: [.font: type(of: self).sourceFont])
		
		func mark(_ range: SourceRange?, in colour: UIColor) {
			guard let range = range else { return }
			formattedText.addAttribute(.foregroundColor, value: colour, range: NSRange(range, in: script.sourceText))
		}
		
		for unit in script.lexicalUnits {
			switch unit {
				
				case .nullaryCommand(instruction: let mnemonicRange, fullRange: _):
				mark(mnemonicRange, in: .mnemonic)
				
				case .registerCommand(instruction: let mnemonicRange, primaryRegister: let firstRegisterRange, secondaryRegister: let secondRegisterRange, fullRange: _):
				mark(mnemonicRange, in: .mnemonic)
				mark(firstRegisterRange.fullRange, in: .operand)
				mark(secondRegisterRange?.fullRange, in: .operand)
				
				case .addressCommand(instruction: let mnemonicRange, addressingMode: let modeRange, register: let registerRange, address: let addressRange, index: _, fullRange: _):
				mark(mnemonicRange, in: .mnemonic)
				mark(modeRange, in: .addressingMode)
				mark(registerRange?.fullRange, in: .operand)
				mark(addressRange, in: .operand)
				
				case .conditionCommand(instruction: let mnemonicRange, addressingMode: let modeRange, condition: let conditionRange, address: let addressRange, index: _, fullRange: _):
				mark(mnemonicRange, in: .mnemonic)
				mark(modeRange, in: .addressingMode)
				mark(conditionRange, in: .operand)
				mark(addressRange, in: .operand)
				
				case .array:
				break
				
				case .zeroArray:
				break
				
				case .label(symbol: _, fullRange: let range):
				formattedText.addAttribute(.underlineStyle, value: NSUnderlineStyle.double.rawValue, range: NSRange(range, in: script.sourceText))
				mark(range, in: .label)
				
				case .comment(let range):
				mark(range, in: .comment)
				
				case .error(let error):
				formattedText.addAttribute(.backgroundColor, value: #colorLiteral(red: 0.9179999828, green: 0.8460000157, blue: 0.8140000105, alpha: 1), range: NSRange(error.sourceRange, in: script.sourceText))
				
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
		
		let oldSelectedRange = textView.selectedRange
		let oldText = textView.text ?? ""
		textView.attributedText = formattedText
		if let newSelectedRange = Range(oldSelectedRange, in: oldText)?.clamped(to: script.sourceText.startIndex..<script.sourceText.endIndex) {
			textView.selectedRange = NSRange(newSelectedRange, in: script.sourceText)
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
			controller.textView.contentInset.bottom = viewFrame.maxY - keyboardFrame.minY
			controller.textView.scrollIndicatorInsets.bottom = viewFrame.maxY - keyboardFrame.minY
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
