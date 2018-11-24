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
	
	private func updatePresentedSourceText() {
		textView?.text = sourceText
	}
	
	/// The presented source error, if any.
	var sourceError: SourceError? {
		didSet {
			if oldValue != nil || sourceError != nil {
				updatePresentedSourceError()
			}
		}
	}
	
	private func updatePresentedSourceError() {
		if let error = sourceError {
			errorBar?.isHidden = false
			errorLabel?.text = "⚠️ \((error as? LocalizedError)?.errorDescription ?? error.localizedDescription) (lijn \(error.lineIndex + 1))"
		} else {
			errorBar?.isHidden = true
			errorLabel?.text = "Geen fouten"
		}
	}
	
	/// The controller's delegate.
	weak var delegate: ScriptEditingControllerDelegate?
	
	/// The text view presenting the script's text.
	@IBOutlet var textView: UITextView!
	
	/// The arranged view hosting the error label.
	@IBOutlet weak var errorBar: UIView!
	
	/// The label presenting a description of the script's source error.
	@IBOutlet weak var errorLabel: UILabel!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		updatePresentedSourceText()
		updatePresentedSourceError()
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
