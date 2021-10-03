// DRAMASimulator © 2018–2021 Constantino Tsarouhas

import SwiftUI

@main
struct Application : App {
	
	// See protocol.
	var body: some Scene {
		DocumentGroup(newDocument: Document()) { configuration in
			NavigationView {
				DocumentView(
					name:		configuration.fileURL?.deletingPathExtension().lastPathComponent ?? "Nieuwe machine",
					document:	configuration.$document
				)
			}
		}
	}
	
}
