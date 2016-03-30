import Cocoa
import Foundation

class Input {
	static func inputLines(file:String?) -> [String] {
		let inputFile = file ?? "input.txt"
		let fh = NSFileHandle(forReadingAtPath:inputFile)

		guard let fileHandle = fh else { return [] as [String] }

		let inputData = fileHandle.readDataToEndOfFile()
		let inputString = (NSString(data: inputData, encoding:NSUTF8StringEncoding) as? String) ?? ""
		let strings = inputString.componentsSeparatedByString("\n")
		return strings
	}
}

class Algorithm {
	typealias Element = Int
	// <Element: Hashable, Comparable>
	static func RandomizedGraphMinCutAlgorithm(graph: Graph) -> Int {
		graph.removeLoops()
		cutEdge(graph);

		let vertices = graph.vertices.sort { graph.graph[$1]!.count > graph.graph[$0]!.count }
		let count = graph.graph[vertices.first!]!.count
		return count
	}

	static func cutEdge(graph: Graph) {

		repeat {
			let randomVertex = chooseRandomVertex(graph)
			let randomConnect = chooseRandomConnect(graph, vertex: randomVertex)

			// #glue together $randomVertex and $randomConnect connects
		 	print("concat \(randomVertex) with \(randomConnect)\n remove \(randomConnect) from graph.");

			graph.graph[randomVertex] = unionArraysWithoutVertexes(graph, one: randomVertex, two: randomConnect);
			renameDestinationVertex(graph, vertex: randomConnect, replacement: randomVertex);

			print("graph vertices: \(graph.vertices)")
			graph.removeLoops()
		}
		while (graph.vertices.count > 2)

		graph.removeLoops()
	}

	static func shuffle(items: [Element]) -> [Element] {
		return items.sort {_, _ in arc4random() % 2 == 0}
	}

	static func chooseRandomVertex(graph: Graph) -> Element {
		return shuffle(graph.vertices).first!
	}

	static func chooseRandomConnect(graph: Graph, vertex: Element) -> Element {
		return shuffle(graph.graph[vertex]!).first!
	}

	static func renameDestinationVertex(graph: Graph, vertex: Element, replacement: Element) {
		let vertices = graph.graph[vertex]!.filter {$0 != replacement}
		for connection in vertices {
			// for others we should rename connection vertex -> replacement
			graph.graph[connection] = graph.graph[connection]!.filter {$0 != vertex} + [replacement]
		}
		graph.removeVertex(vertex)
	}

	static func unionArraysWithoutVertexes(graph: Graph, one: Element, two: Element) -> [Element] {
		let firstConnections = graph.graph[one]!
		let secondConnections = graph.graph[two]!
		return (firstConnections + secondConnections).sort(>).filter {$0 != one && $0 != two}
	}
}

class Graph {
	var graph: [Int: [Int]]
	init(lines: [String]) {
		var graph: [Int: [Int]] = [:]
		let lists = lines.map{ $0.componentsSeparatedByString(" ") }
		for list in lists {
			graph[Int(list.first!)!] = list.dropFirst().sort(>).map { Int($0)! }
		}
		self.graph = graph
	}

	var vertices: [Int] {
		return Array(graph.keys)
	}

	func removeLoops() {
		for vertex in vertices {
			self.graph[vertex] = self.graph[vertex]!.filter {$0 != vertex}
		}
	}

	func removeVertex(vertex: Int) {
		graph[vertex] = nil
	}
}

class Solution {
    static func main(args:[String]) {
        let lines = Input.inputLines(args.dropFirst().first)
        // each line should be converted to array of arrays

        var array:[Int] = []
        for _ in 1...100 {
	        let graph = Graph(lines: lines)
	        let result = Algorithm.RandomizedGraphMinCutAlgorithm(graph)
	        array.append(result)
        }
        print("count: \(array.minElement()!)")
    }
}

Solution.main(Process.arguments)