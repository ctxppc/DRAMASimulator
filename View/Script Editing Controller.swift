// DRAMASimulator © 2018 Constantino Tsarouhas

import UIKit

final class ScriptEditingController : UIViewController {
	
	/// The script being edited.
	var script: ScriptDocument? {
		didSet { presentText() }
	}
	
	/// The text view presenting the script's text.
	@IBOutlet var textView: UITextView! {
		didSet { presentText() }
	}
	
	/// Presents the script's text, replacing the contents of the text view.
	private func presentText() {
		textView?.text = script?.sourceText ?? ""
	}
	
}

extension ScriptEditingController : UITextViewDelegate {
	func textViewDidChange(_ textView: UITextView) {
		script?.sourceText = textView.text
	}
}
