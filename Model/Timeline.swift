// DRAMASimulator © 2018–2020 Constantino Tsarouhas

import Foundation
import os

/// A value that represents all states of a machine during its execution.
struct Timeline {
	
	/// Creates a timeline with given machine as starting point.
	init(machine: Machine) {
		self.machine = machine
	}
	
	/// The machine at the current point.
	var machine: Machine
	
	/// The machines at previous points, from earliest to latest.
	///
	/// The last machine in `previousMachines`, if any, immediately precedes `currentMachine` in the timeline.
	private(set) var previousMachines: [Machine] = []
	
	/// Whether the timeline can move backward.
	var canRewind: Bool { !previousMachines.isEmpty }
	
	/// Moves the timeline one step backward.
	///
	/// - Requires: `canRewind`.
	mutating func rewind() {
		machine = previousMachines.removeLast()
	}
	
	/// Whether the timeline can move forward.
	var canProceed: Bool { machine.state == .ready }
	
	/// Moves the timeline one step forward.
	///
	/// - Requires: `canProceed`.
	mutating func proceed() throws {
		let previousMachine = machine
		try machine.executeNext()
		previousMachines.append(previousMachine)
	}
	
	/// Provides input to the machine and resumes execution if it paused to wait for input.
	///
	/// While the machine is modified by providing it input, the `currentMachineDidChange(on:)` delegate method is _not_ invoked as a result of that change.
	///
	/// - Requires: `machine.state` is `.waitingForInput`.
	mutating func provideMachineInput(_ input: MachineWord) {
		machine.provideInput(input)
	}
	
}
