// DRAMASimulator © 2018–2020 Constantino Tsarouhas

import SwiftUI

@main
struct Application : App {
	
	// See protocol.
	var body: some Scene {
		DocumentGroup(newDocument: Document()) { configuration in
			DocumentView(
				name:		configuration.fileURL?.deletingPathExtension().lastPathComponent ?? "Nieuwe machine",
				document:	configuration.$document
			)
		}
	}
	
}
