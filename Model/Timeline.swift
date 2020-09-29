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
	var canAdvance: Bool { machine.state.isReady }
	
	/// Moves the timeline one step forward.
	///
	/// - Requires: `canAdvance`.
	mutating func advance() {
		
		previousMachines.append(machine)
		machine.executeNext()
		
		if previousMachines.count >= purgeRange.upperBound {
			previousMachines.removeFirst(purgeRange.upperBound - purgeRange.lowerBound)
		}
		
	}
	
	/// The possible number of machines in the timeline where machines are purged.
	///
	/// When the number of machines in the timeline lies in this range, purging may have occurred. The number of machines does not exceed the range's upper bound.
	///
	/// The range should be sufficiently wide to avoid frequent reallocations.
	private let purgeRange = 7500...10000
	
}
