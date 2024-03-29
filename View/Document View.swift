// DRAMASimulator © 2018–2021 Constantino Tsarouhas

import SwiftUI

/// A view that presents a document.
struct DocumentView : View {
	
	/// Creates a view for emulating and editing given script.
	init(name: String, document: Binding<Document>) {
		self.name = name
		self._document = document
	}
	
	/// The document's name.
	let name: String
	
	/// The document being presented.
	@Binding
	private var document: Document
	
	/// The view's horizontal size class.
	@Environment(\.horizontalSizeClass)
	private var sizeClass
	
	/// A timer publisher for animating executions.
	private let normalClock = Timer.publish(every: 0.75, on: .main, in: .common).autoconnect()
	
	/// A timer publisher for animating executions quickly.
	private let fastClock = Timer.publish(every: 0.15, on: .main, in: .common).autoconnect()
	
	/// A value indicating whether and how the timeline is animated.
	@State
	private var timelineAnimation: TimelineAnimation = .paused
	enum TimelineAnimation {
		case rewind, paused, play, fastForward
	}
	
	/// The user input.
	@State
	private var input = ""
	
	// See protocol.
	var body: some View {
		SplitView(ratio: 0.5, range: 0.25...0.75) {
			ScriptEditor(script: $document.script, programCounter: $document.machine.programCounter)
			MachineView(machine: document.machine)
		}.overlay(statusBar, alignment: .top)
		.background(timer)
		.navigationTitle(name)
		.navigationBarTitleDisplayMode(.inline)
		.toolbar {
			ToolbarItemGroup(placement: sizeClass == .compact ? .bottomBar : .navigationBarLeading) {
				Button(action: { rewind() }) {
					Label("Step Backward", systemImage: "backward.frame")
				}.disabled(!document.timeline.canRewind || timelineAnimation != .paused)
				bottomBarSpacer
				Button(action: { advance() }) {
					Label("Step Forward", systemImage: "forward.frame")
				}.disabled(!document.timeline.canAdvance || timelineAnimation != .paused)
				bottomBarSpacer
			}
			ToolbarItemGroup(placement: sizeClass == .compact ? .bottomBar : .navigationBarTrailing) {
				Button(action: { timelineAnimation = .rewind }) {
					Label("Rewind", systemImage: "backward.fill")
				}.disabled(!document.timeline.canRewind)
				bottomBarSpacer
				if timelineAnimation != .paused {
					Button(action: { timelineAnimation = .paused }) {
						Label("Pause", systemImage: "pause.fill")
					}
				} else {
					Button(action: { timelineAnimation = .play }) {
						Label("Play", systemImage: "play.fill")
					}.disabled(!document.timeline.canAdvance)
				}
				bottomBarSpacer
				Button(action: { timelineAnimation = .fastForward }) {
					Label("Fast Forward", systemImage: "forward.fill")
				}.disabled(!document.timeline.canAdvance)
			}
		}
	}
	
	@ViewBuilder
	private var bottomBarSpacer: some View {
		if sizeClass == .compact {
			Spacer()
		}
	}
	
	@ViewBuilder
	private var timer: some View {
		switch timelineAnimation {
			case .rewind:		Color.clear.onReceive(fastClock) { _ in rewind(steps: 10) }
			case .paused:		Color.clear
			case .play:			Color.clear.onReceive(normalClock) { _ in advance() }
			case .fastForward:	Color.clear.onReceive(fastClock) { _ in advance(steps: 10) }
		}
	}
	
	private func rewind(steps: Int = 1) {
		withAnimation {
			for _ in 1...steps {
				if document.timeline.canRewind {
					document.timeline.rewind()
				} else {
					timelineAnimation = .paused
					break
				}
			}
		}
	}
	
	private func advance(steps: Int = 1) {
		withAnimation {
			for _ in 1...steps {
				if document.timeline.canAdvance {
					document.timeline.advance()
				} else if timelineAnimation != .paused {
					timelineAnimation = .paused
					break
				}
			}
		}
	}
	
	private var statusBar: some View {
		let machine = document.machine
		let scriptErrors = document.script.product.errors
		return Group {
			if machine.state.isWaitingForInput || machine.state.error != nil || !scriptErrors.isEmpty {
				VStack(alignment: .leading, spacing: 8) {
					if machine.state.isWaitingForInput {
						HStack {
							Label("Invoer vereist:", systemImage: "text.cursor")
							TextField("Invoer", text: $input, onCommit: provideInput)
								.keyboardType(.asciiCapableNumberPad)
								.multilineTextAlignment(.trailing)
								.frame(maxWidth: 100)
								.padding()
							Button("Ga door", action: provideInput)
								.disabled(Int(input) == nil)
								.padding()
						}
					}
					if let error = machine.state.error {
						Label((error as? LocalizedError)?.errorDescription ?? error.localizedDescription, systemImage: "xmark.octagon.fill")
					}
					ForEach(scriptErrors.indices, id: \.self) { index in
						Label((scriptErrors[index] as? LocalizedError)?.errorDescription ?? scriptErrors[index].localizedDescription, systemImage: "xmark.octagon.fill")
					}
				}.padding()
				.background(Color(.secondarySystemBackground).opacity(0.75))
				.clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
				.padding()
				.shadow(radius: 10)
			}
		}
	}
	
	func provideInput() {
		document.machine.provideInput(.init(wrapping: Int(input) ?? 0))
	}
	
}

private extension Double {
	var cgFloat: CGFloat {
		get { .init(self) }
		set { self = .init(newValue) }
	}
}

#if DEBUG
struct DocumentViewPreviews : PreviewProvider {
	
	static var previews: some View {
		Demo()
	}
	
	private struct Demo : View {
		
		@State
		var document = Document(script: templateScript)
		
		var body: some View {
			NavigationView {
				DocumentView(name: "Preview", document: $document)
			}.navigationViewStyle(StackNavigationViewStyle())
		}
		
	}
	
}

let templateScript = Script(from:
	"""
	HIA.w R0, 20
	OPT R0, R1
	STP
	"""
)
#endif
