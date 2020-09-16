// DRAMASimulator © 2018–2020 Constantino Tsarouhas

import Foundation

/// An object that represents all states of a machine during its execution.
final class Timeline {
	
	/// Creates a timeline with given machine as starting point.
	init(machine: Machine) {
		currentMachine = machine
	}
	
	/// The timeline's delegate.
	weak var delegate: TimelineDelegate?
	
	/// The machine at the current point.
	private(set) var currentMachine: Machine
	
	/// The machines at previous points, from earliest to latest.
	///
	/// The last machine in `previousMachines`, if any, immediately precedes `currentMachine` in the timeline.
	private(set) var previousMachines: [Machine] = []
	
	/// Whether the timeline can move backward.
	var canRewind: Bool {
		return !previousMachines.isEmpty
	}
	
	/// Provides input to the machine and resumes execution if it paused to wait for input.
	///
	/// While the machine is modified by providing it input, the `currentMachineDidChange(on:)` delegate method is _not_ invoked as a result of that change.
	///
	/// - Requires: `machine.state` is `.waitingForInput`.
	func provideMachineInput(_ input: Word) {
		currentMachine.provideInput(input)
		if pausedForInput {
			direction = .forward
			pausedForInput = false
		}
	}
	
	private(set) var pausedForInput = false
	
	/// The speed at which the timeline moves forward or backward.
	///
	/// Any changes to this property only apply after pausing and resuming the machine.
	///
	/// - Requires: `animationSpeed` ≥ 0.01 seconds.
	var animationSpeed: TimeInterval = 0.1 {
		willSet { precondition(newValue >= 0.01) }
	}
	
	/// The direction in which the timeline currently moves.
	///
	/// Setting the direction to `.forward` when the machine is halted, waits for input, or fails to execute the next command results in the appropriate delegate methods being invoked again before the timeline is stopped again.
	var direction: Direction = .still {
		didSet {
			guard direction != oldValue else { return }
			animationTimer?.invalidate()
			switch direction {
				case .still:				animationTimer = nil
				case .forward, .backward:	animationTimer = .scheduledTimer(withTimeInterval: animationSpeed, repeats: true) { [weak self] _ in self?.timedMove() }
			}
		}
	}
	
	enum Direction {
		
		/// The timeline does not move.
		case still
		
		/// The timeline moves forward.
		case forward
		
		/// The timeline moves backward.
		case backward
		
	}
	
	/// The timer that fires for every step, or `nil` if the timeline isn't moving.
	private var animationTimer: Timer?
	
	/// Moves the timeline in response to the animation timer firing.
	private func timedMove() {
		switch direction {
			case .still:	assert(animationTimer == nil, "We're in a useless loop or there are zombie timers.")
			case .forward:	moveForward()
			case .backward:	moveBackward()
		}
	}
	
	/// Moves the timeline one step forwards.
	func moveForward() {
		switch currentMachine.state {
			
			case .ready:
			do {
				let previousMachine = currentMachine
				try currentMachine.executeNext()
				previousMachines.append(previousMachine)
				delegate?.currentMachineDidChange(on: self)
			} catch {
				direction = .still
				delegate?.machineExecutionDidFail(withError: error, on: self)
			}
			
			case .waitingForInput:
			pausedForInput = direction != .still
			direction = .still
			delegate?.machineWaitsForInput(on: self)
			
			case .halted:
			direction = .still
			delegate?.timelineDidFinishMoving(on: self)
			
		}
	}
	
	/// Moves the timeline one step backwards.
	func moveBackward() {
		if canRewind {
			currentMachine = previousMachines.removeLast()
			delegate?.currentMachineDidChange(on: self)
		} else {
			direction = .still
			delegate?.timelineDidFinishMoving(on: self)
		}
	}
	
	deinit {
		animationTimer?.invalidate()
	}
	
}

protocol TimelineDelegate : class {
	
	/// Notifies the delegate that the document's machine has been modified.
	func currentMachineDidChange(on timeline: Timeline)
	
	/// Notifies the delegate that the document's machine's execution failed and that the machine's execution is stopped.
	func machineExecutionDidFail(withError error: Error, on timeline: Timeline)
	
	/// Notifies the delegate that the document's machine requires input and that the machine's execution is stopped.
	func machineWaitsForInput(on timeline: Timeline)
	
	/// Notifies the delegate that the timeline has finished moving.
	func timelineDidFinishMoving(on timeline: Timeline)
	
}
