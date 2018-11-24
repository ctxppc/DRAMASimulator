// DRAMASimulator © 2018 Constantino Tsarouhas

import UIKit

/// A view controller that presents the contents of a document's source text.
final class ScriptEditingController : UIViewController {
	
	/// The presented source text.
	var sourceText: String = "" {
		didSet {
			guard oldValue != sourceText else { return }
			updatePresentedSourceText()
		}
	}
	
	/// The presented source errors, if any.
	var sourceErrors: [SourceError] = [] {
		didSet { updatePresentedSourceErrors() }
	}
	
	private func updatePresentedSourceText() {
		self.textView.text = sourceText
		updatePresentedSourceErrors()
	}
	
	private func updatePresentedSourceErrors() {
		
		guard let errorBar = errorBar, let errorLabel = errorLabel, let textView = textView else { return }
		if sourceErrors.isEmpty {
			textView.text = sourceText
			errorBar.isHidden = true
			errorLabel.text = "Geen fouten"
			return
		}
		
		errorBar.isHidden = false
		errorLabel.text = sourceErrors.map { sourceError in
			let error = sourceError.underlyingError
			return "⚠️ \((error as? LocalizedError)?.errorDescription ?? error.localizedDescription)"
		}.joined(separator: "\n")
		
		textView.textStorage.removeAttribute(.backgroundColor, range: NSRange(textView.text.startIndex..<textView.text.endIndex, in: textView.text))
		for error in sourceErrors where error.range.upperBound < sourceText.endIndex {
			textView.textStorage.addAttribute(.backgroundColor, value: #colorLiteral(red: 0.9179999828, green: 0.8460000157, blue: 0.8140000105, alpha: 1), range: NSRange(error.range, in: sourceText))
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
		updatePresentedSourceText()
	}
	
}

extension ScriptEditingController : UITextViewDelegate {
	func textViewDidChange(_ textView: UITextView) {
		sourceText = textView.text
		delegate?.scriptEditingControllerDidChangeSourceText(self)
	}
}

protocol ScriptEditingControllerDelegate : class {
	
	/// Notifies the delegate that the source text has been changed.
	func scriptEditingControllerDidChangeSourceText(_ controller: ScriptEditingController)
	
}
