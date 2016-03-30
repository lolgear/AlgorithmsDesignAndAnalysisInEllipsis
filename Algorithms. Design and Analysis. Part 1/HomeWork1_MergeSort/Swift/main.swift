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

class Algorithm<Element: Comparable> {

	static func MergeSortAndCountInversions(elements: [Element]) -> (Int, [Element], Int) {
		let n = elements.count
		let half = (n / 2)
		// print("n: \(n) and half: \(half)")
		guard n >= 2 else { return (0, elements, n) }
		let leftPart = Array(elements[0...half-1])
		let rightPart = Array(elements[half...n-1])
		// print("in Main: 0..\(n-1) whole array: \(elements)")
		// print("in Main: 0..\(half-1) leftArray: \(leftPart)")
		// print("in Main: \(half)..\(n-1) rightArray: \(rightPart)")
		let (leftCount, leftArray, leftSize) = MergeSortAndCountInversions(leftPart)
		let (rightCount, rightArray, rightSize) = MergeSortAndCountInversions(rightPart)
		let (splitCount, mergedArray, mergedSize) = MergeAndSplitAndCountInversions(leftArray, leftSize, rightArray, rightSize)
		return (leftCount + rightCount + splitCount, mergedArray, mergedSize)
	}

	static func MergeAndSplitAndCountInversions(leftArray:[Element], _ leftSize:Int, _ rightArray:[Element], _ rightSize:Int) -> (Int, [Element], Int) {
		let n = leftSize + rightSize
		var outputArray: [Element] = []
		var leftIndex = 0
		var rightIndex = 0
		var inversionCount = 0

		// print("in Split: leftCount:\(leftSize) leftArray: \(leftArray)")
		// print("in Split: rightCount:\(rightSize) rightArray: \(rightArray)")


		for _ in 0..<n {
			let rightValid = rightIndex < rightSize
			let leftValid = leftIndex < leftSize
			if (rightValid && leftValid) {

				if (rightArray[rightIndex] > leftArray[leftIndex]) {
					outputArray.append(leftArray[leftIndex])
					leftIndex = leftIndex + 1
				}
				else if (leftArray[leftIndex] > rightArray[rightIndex]) {
					inversionCount = inversionCount + leftSize - leftIndex
					outputArray.append(rightArray[rightIndex])
					rightIndex = rightIndex + 1
				}
			}
			else {
				if (!rightValid) {
					if (leftValid) {
						outputArray.append(leftArray[leftIndex])
						leftIndex = leftIndex + 1
					}
				}

				if (!leftValid) {
					if (rightValid) {
						outputArray.append(rightArray[rightIndex])
						rightIndex = rightIndex + 1
					}
				}
			}
		}
		return (inversionCount, outputArray, n)
	}
}

class Solution {
    static func main(args:[String]) {
        let lines = Input.inputLines(args.dropFirst().first)
        let numbers = lines.map{Int($0)}.flatMap{$0}
        let result = Algorithm.MergeSortAndCountInversions(numbers)
        print("inversions: \(result.0)")
    }
}

Solution.main(Process.arguments)