// DRAMASimulator © 2018 Constantino Tsarouhas

import UIKit

/// A view controller that presents the contents of a document's source text.
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
		guard let script = script else { return }
		let previousText = script.sourceText
		script.sourceText = textView.text
		script.undoManager!.registerUndo(withTarget: script) { script in
			script.sourceText = previousText
		}
	}
}
