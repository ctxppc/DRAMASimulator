// DRAMASimulator © 2018–2020 Constantino Tsarouhas

import UIKit

extension UIViewController {
	
	/// Presents an error to the user.
	///
	/// This method must only be called whilst the view is visible.
	///
	/// - Parameter error: The error to present to the user.
	/// - Parameter completion: A closure that is invoked when the user dismisses the alert. The default value does nothing.
	func present(_ error: Error, then completion: @escaping () -> () = {}) {
		
		if let error = error as? RecoverableError {
			return present(error, then: { _ in completion() })
		}
		
		let controller = UIViewController.bareAlertController(for: error)
		controller.addAction(UIAlertAction(title: "OK", style: .default) { _ in
			completion()
		})
		
		present(controller, animated: true, completion: nil)
		
	}
	
	/// Presents an error to the user.
	///
	/// This method must only be called whilst the view is visible.
	///
	/// - Parameter error: The error to present to the user.
	/// - Parameter completion: A closure that is invoked when the user dismisses the alert. If the user chooses a recovery option, it is attempted and the closure is passed an attempted recovery value. The default value does nothing.
	func present(_ error: RecoverableError, then completion: @escaping (AttemptedRecovery?) -> ()) {
		
		let controller = UIViewController.bareAlertController(for: error)
		for (index, option) in error.recoveryOptions.enumerated() {
			controller.addAction(UIAlertAction(title: option, style: .default) { _ in
				completion(AttemptedRecovery(optionIndex: index, succeeded: error.attemptRecovery(optionIndex: index)))
			})
		}
		
		present(controller, animated: true, completion: nil)
		
	}
	
	/// A value indicating the recovery option selected by the user and whether it has been successfully attempted.
	struct AttemptedRecovery {
		
		/// The index of the option in the recoverable error's array of options.
		let optionIndex: Int
		
		/// Whether recovery has been successful.
		let succeeded: Bool
		
	}
	
	/// Returns an alert controller configured for a given error but without any alert actions.
	private static func bareAlertController(for error: Error) -> UIAlertController {
		return UIAlertController(
			title:			(error as? LocalizedError)?.errorDescription ?? error.localizedDescription,
			message:		(error as? LocalizedError)?.recoverySuggestion ?? (error as NSError).localizedRecoverySuggestion,
			preferredStyle:	.alert
		)
	}
	
}
