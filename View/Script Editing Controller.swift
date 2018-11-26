// DRAMASimulator © 2018 Constantino Tsarouhas

import UIKit

/// A view controller that presents the contents of a document's source text.
final class ScriptEditingController : UIViewController {
	
	/// The presented script.
	var script: Script = .init() {
		didSet { updatePresentedScript() }
	}
	
	/// A presented source error that is not part of the script.
	var additionalSourceError: SourceError?	{	// FIXME: Code smell
		didSet { updatePresentedScript() }
	}
	
	/// The font for presenting source text.
	private static let sourceFont = UIFont(name: "Menlo", size: 18)!
	
	private func updatePresentedScript() {
		
		guard let errorBar = errorBar, let errorLabel = errorLabel, let textView = textView else { return }
		
		let sourceErrors: [SourceError]
		if let error = additionalSourceError {
			sourceErrors = script.sourceErrors() + [error]
		} else {
			sourceErrors = script.sourceErrors()
		}
		
		if sourceErrors.isEmpty {
			errorBar.isHidden = true
			errorLabel.text = "Geen fouten"
		} else {
			errorBar.isHidden = false
			errorLabel.text = sourceErrors.map { sourceError in
				let error = sourceError.underlyingError
				return "⚠️ \((error as? LocalizedError)?.errorDescription ?? error.localizedDescription)"
			}.joined(separator: "\n")
		}
		
		let formattedText = NSMutableAttributedString(string: script.text, attributes: [.font: type(of: self).sourceFont])
		
		for error in sourceErrors {
			formattedText.addAttribute(.backgroundColor, value: #colorLiteral(red: 0.9179999828, green: 0.8460000157, blue: 0.8140000105, alpha: 1), range: NSRange(error.range, in: script.text))
		}
		
		let rangesByColour: KeyValuePairs<UIColor, [Script.SourceRange]> = [
			.mnemonic:			script.syntaxMap.mnemonicRanges,
			.addressingMode:	script.syntaxMap.addressingModeRanges,
			.registerOperands:	script.syntaxMap.registerOperandRanges,
			.baseAddress:		script.syntaxMap.baseAddressRanges,
			.addressIndex:		script.syntaxMap.addressIndexRanges,
			.comment:			script.syntaxMap.commentRanges
		]
		
		for (colour, ranges) in rangesByColour {
			for range in ranges {
				formattedText.addAttribute(.foregroundColor, value: colour, range: NSRange(range, in: script.text))
			}
		}
		
		let oldSelectedRange = textView.selectedRange
		let oldText = textView.text ?? ""
		textView.attributedText = formattedText
		if let newSelectedRange = Range(oldSelectedRange, in: oldText)?.clamped(to: script.text.startIndex..<script.text.endIndex) {
			textView.selectedRange = NSRange(newSelectedRange, in: script.text)
		}
		
	}
	
	/// The controller's delegate.
	weak var delegate: ScriptEditingControllerDelegate?
	
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
	
}

extension ScriptEditingController : UITextViewDelegate {
	func textViewDidChange(_ textView: UITextView) {
		script.text = textView.text
		delegate?.sourceTextDidChange(on: self)
	}
}

protocol ScriptEditingControllerDelegate : class {
	
	/// Notifies the delegate that the source text has been changed.
	func sourceTextDidChange(on controller: ScriptEditingController)
	
}

extension UIColor {
	static let mnemonic = red
	static let addressingMode = green
	static let baseAddress = blue
	static let registerOperands = cyan
	static let addressIndex = brown
	static let comment = gray
}
