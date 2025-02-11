// Copyright 2019 The TensorFlow Authors. All Rights Reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import XCTest
@testable import TensorFlow

final class MathOperatorTests: XCTestCase {
    func testElementaryFunction(
        name: String,
        _ tensorOperator: (Tensor<Float>) -> Tensor<Float>,
        _ scalarOperator: (Float) -> Float,
        accuracy: Float = 1e-4,
        file: StaticString = #file, line: UInt = #line
    ) {
        let x = Tensor<Float>(randomNormal: [20], seed: (0, 0))
        let actual = tensorOperator(x).scalars
        let expected = x.scalars.map(scalarOperator)
        assertEqual(actual, expected, accuracy: accuracy, name, file: file, line: line)
    }

    func testElementaryFunctions() {
        testElementaryFunction(name: "sqrt", sqrt, Float.sqrt)
        testElementaryFunction(name: "cos", cos, Float.cos)
        testElementaryFunction(name: "sin", sin, Float.sin)
        testElementaryFunction(name: "tan", tan, Float.tan)
        testElementaryFunction(name: "cosh", cosh, Float.cosh)
        testElementaryFunction(name: "sinh", sinh, Float.sinh)
        testElementaryFunction(name: "tanh", tanh, Float.tanh)
        testElementaryFunction(name: "acos", acos, Float.acos)
        testElementaryFunction(name: "asin", asin, Float.asin)
        testElementaryFunction(name: "atan", atan, Float.atan)
        testElementaryFunction(name: "acosh", acosh, Float.acosh)
        testElementaryFunction(name: "asinh", asinh, Float.asinh)
        testElementaryFunction(name: "atanh", atanh, Float.atanh)
        testElementaryFunction(name: "exp", exp, Float.exp)
        testElementaryFunction(name: "exp2", exp2, Float.exp2)
        testElementaryFunction(name: "exp10", exp10, Float.exp10)
        testElementaryFunction(name: "expm1", expm1, Float.expm1)
        testElementaryFunction(name: "log", log, Float.log)
        testElementaryFunction(name: "log2", log2, Float.log2)
        testElementaryFunction(name: "log10", log10, Float.log10)
        testElementaryFunction(name: "log1p", log1p, Float.log1p)
        testElementaryFunction(name: "pow",
                               { x in pow(x, x) }, { x in Float.pow(x, x) })
        testElementaryFunction(name: "pow",
                               { x in pow(x, 3) }, { x in Float.pow(x, 3) })
        testElementaryFunction(name: "root",
                               { x in root(x, 3) }, { x in Float.root(x, 3) })
    }

    func testLog1p() {
        let x = Tensor<Float>([1, 2, 3, 4, 5])
        let y = log1p(x)
        let expectedY = Tensor<Float>([0.69315, 1.09861, 1.38629, 1.60944, 1.79176])
        assertEqual(y, expectedY, accuracy: 0.0001)
    }

    func testLog1mexp() {
        let x = Tensor<Float>([-1, -2, -3, -4, -5])
        let y = log1mexp(x)
        let expectedY = Tensor<Float>([-0.45868, -0.14541, -0.05107, -0.01849, -0.00676])
        assertEqual(y, expectedY, accuracy: 0.0001)
    }

    func testExpm1() {
        let x = Tensor<Float>([1, 2, 3, 4, 5])
        let y = expm1(x)
        let expectedY = Tensor<Float>([1.71828, 6.38906, 19.08554, 53.59815, 147.41316])
        assertEqual(y, expectedY, accuracy: 0.0001)
    }

    func testSign() {
        let x = Tensor<Float>([[1, 2, -3, 4, 5], [1, 2, 3, 4, -5]])
        let y = sign(x)
        XCTAssertEqual(y, Tensor<Float>([[1, 1, -1, 1, 1], [1, 1, 1, 1, -1]]))
    }

    func testLogSigmoid() {
        let x = Tensor<Float>([[1, 2, 3, 4, 5], [1, 2, 3, 4, 5]])
        let y = logSigmoid(x)
        assertEqual(y, log(sigmoid(x)), accuracy: 0.0001)
    }

    func testSoftplus() {
        let x = Tensor<Float>([1.0, 2.0, 3.0])
        let y = softplus(x)
        let expected = Tensor<Float>([1.3132616,  2.126928, 3.0485873])
        XCTAssertEqual(y, expected)
    }

    func testSoftsign() {
        let x = Tensor<Float>([1.0, 4.0, 3.0])
        let y = softsign(x)
        let expected = Tensor<Float>([0.5 , 0.8 , 0.75])
        XCTAssertEqual(y, expected)
    }

    func testElu() {
        let x = Tensor<Float>([-1.0, 2.0, 3.0])
        let y = elu(x)
        let expected = Tensor<Float>([-0.63212055, 2, 3])
        XCTAssertEqual(y, expected)
    }

    func testGelu() {
        let x = Tensor<Float>([2.0, 1.0, 7.0])
        let y = gelu(x)
        let expected = Tensor<Float>([1.95459769, 0.84119199, 7.0])
        XCTAssertEqual(y, expected)
    }

    func testLeakyRelu() {
        let x = Tensor<Float>([[-1.0, 2.0, 3.0]])
        let y = leakyRelu(x, alpha: 0.4)
        let expected = Tensor<Float>([-0.4, 2, 3])
        XCTAssertEqual(y, expected)
    }

    func testIsFinite() {
        let x = Tensor<Float>([1, 2, 3, 4, -Float.infinity])
        let y = x.isFinite
        XCTAssertEqual(y, Tensor([true, true, true, true, false]))
    }

    func testIsInfinite() {
        let x = Tensor<Float>([1, 2, 3, 4, log(0.0)])
        let y = x.isInfinite
        XCTAssertEqual(y, Tensor([false, false, false, false, true]))
    }

    func testIsNaN() {
        let x = Tensor<Float>([1, 2, 3, 4, log(-5.0)])
        let y = x.isNaN
        XCTAssertEqual(y, Tensor([false, false, false, false, true]))
    }

    func testCosineSimilarity() {
        let x = Tensor<Float>([1, 2, 3, 4, 5, 6, 7, 8])
        let y = Tensor<Float>([0.5, 1, 1.5, 2.0, 2.5, 3.0, 3.5, 4.0])
        let z = cosineSimilarity(x, y)
        let output: Float = 1.0
        XCTAssertEqual(z, Tensor(output))
    }

    func testReduction() {
        // 2 x 5
        let x = Tensor<Float>([[1, 2, 3, 4, 5], [1, 2, 3, 4, 5]])
        XCTAssertEqual(x.sum(), Tensor(30))
        XCTAssertEqual(
            x.sum(squeezingAxes: 0),
            Tensor(shape: [5], scalars: [2, 4, 6, 8, 10]))
        XCTAssertEqual(
            x.sum(alongAxes: 0),
            Tensor(shape: [1, 5], scalars: [2, 4, 6, 8, 10]))

        XCTAssertEqual(x.product(), Tensor(14400))
        XCTAssertEqual(
            x.product(squeezingAxes: 0),
            Tensor(shape: [5], scalars: [1, 4, 9, 16, 25]))
        XCTAssertEqual(
            x.product(alongAxes: 0),
            Tensor(shape: [1, 5], scalars: [1, 4, 9, 16, 25]))

        XCTAssertEqual(x.mean(), Tensor(3))
        XCTAssertEqual(
            x.mean(squeezingAxes: 0),
            Tensor(shape: [5], scalars: [1, 2, 3, 4, 5]))
        XCTAssertEqual(
            x.mean(alongAxes: 0),
            Tensor(shape: [5], scalars: [1, 2, 3, 4, 5]))
        XCTAssertEqual(
            x.mean(squeezingAxes: 1),
            Tensor(shape: [2], scalars: [3, 3]))
        XCTAssertEqual(
            x.mean(alongAxes: 1),
            Tensor(shape: [1, 2], scalars: [3, 3]))

        XCTAssertEqual(x.variance(), Tensor(2))
        XCTAssertEqual(
            x.variance(squeezingAxes: 0),
            Tensor(shape: [5], scalars: [0, 0, 0, 0, 0]))
        XCTAssertEqual(
            x.variance(alongAxes: 0),
            Tensor(shape: [5], scalars: [0, 0, 0, 0, 0]))
        XCTAssertEqual(
            x.variance(squeezingAxes: 1),
            Tensor(shape: [2], scalars: [2, 2]))
        XCTAssertEqual(
            x.variance(alongAxes: 1),
            Tensor(shape: [1, 2], scalars: [2, 2]))
    }

    func testArgmax() {
        // 2 x 3
        let x = Tensor<Float>([[0, 1, 2], [3, 4, 5]])
        let argmax0 = x.argmax(squeezingAxis: 0)
        let argmax1 = x.argmax(squeezingAxis: 1)
        let scalarsArgmax = x.argmax()
        XCTAssertEqual(argmax0.array, ShapedArray(shape: [3], scalars: [1, 1, 1]))
        XCTAssertEqual(argmax1.array, ShapedArray(shape: [2], scalars: [2, 2]))
        XCTAssertEqual(scalarsArgmax.array, ShapedArray(shape: [], scalars: [5]))
    }

    func testLogSumExp() {
        let x = Tensor<Float>([
            [0.45031791, 0.41123222, 0.53928467, 0.47167023, 0.15483777],
            [0.49975705, 0.71807549, 0.30396056, 0.2690469 , 0.01404393],
            [0.16950939, 0.41085612, 0.79503016, 0.11977817, 0.99728241],
            [0.62510073, 0.17344792, 0.1540605 , 0.40758517, 0.93683817],
            [0.15653343, 0.50502756, 0.99365925, 0.84617581, 0.17422509]])
        let y0 = x.logSumExp()
        let y1 = x.logSumExp(squeezingAxes: 1)
        let y2 = x.logSumExp(alongAxes: 1)
        let expectedY0 = Tensor<Float>(3.713885997817954)
        let expectedY1 = Tensor<Float>(
            [2.02318908, 1.99835067, 2.16853826, 2.1137799, 2.20261244])
        let expectedY2 = Tensor<Float>(
            [[2.02318908], [1.99835067], [2.16853826], [2.1137799], [2.20261244]])
        assertEqual(y0, expectedY0, accuracy: 0.0001)
        assertEqual(y1, expectedY1, accuracy: 0.0001)
        assertEqual(y2, expectedY2, accuracy: 0.0001)
    }

    func testCeilAndFloor() {
        let x = Tensor<Float>([-1.3, -0.4, 0.5, 1.6])
        let xFloor = floor(x)
        let xCeil = ceil(x)
        XCTAssertEqual(xFloor.array, ShapedArray(shape: [4], scalars: [-2, -1, 0, 1]))
        XCTAssertEqual(xCeil.array, ShapedArray(shape: [4], scalars: [-1, 0, 1, 2]))
    }

    func testSimpleMath() {
        let x = Tensor<Float>([1.2, 1.2])
        let y = tanh(x)
        let array = y.array
        XCTAssertEqual([2], array.shape)
        XCTAssertEqual(Double(array.scalars[0]), 0.833655, accuracy: 0.0001)
        XCTAssertEqual(Double(array.scalars[1]), 0.833655, accuracy: 0.0001)
    }

    func testStandardDeviation() {
        XCTAssertEqual(Tensor<Float>([1]).standardDeviation(), Tensor(0))
        XCTAssertEqual(Tensor<Float>([0, 1]).standardDeviation(alongAxes: 0), Tensor(0.5))
        XCTAssertEqual(Tensor<Float>([0, 1]).standardDeviation(), Tensor(0.5))
        XCTAssertEqual(
            Tensor<Float>(rangeFrom: 0, to: 10, stride: 1).standardDeviation().scalarized(),
            2.87228132,
            accuracy: 0.001)
        let matrix = Tensor<Float>(rangeFrom: 0, to: 10, stride: 1).reshaped(to: [2, 5])
        XCTAssertEqual(matrix.standardDeviation().scalarized(), 2.87228132, accuracy: 0.001)
        let values = matrix.standardDeviation(alongAxes: 1).array.scalars
        XCTAssertEqual(Double(values[0]), 1.4142, accuracy: 0.0001)
        XCTAssertEqual(Double(values[1]), 1.4142, accuracy: 0.0001)
    }

    func test3Adds() {
        let a = Tensor<Float>([1])
        let b = Tensor<Float>([2])
        let c = Tensor<Float>([3])

        let o = a + b + c
        XCTAssertEqual(o.scalars, [6])
    }

    func testMultiOpMath() {
        let x = Tensor<Float>([1.2, 1.2])
        let y = Tensor<Float>([2.4, 2.4])
        let t1 = x + y
        let t2 = t1 * t1
        let t3 = sqrt(t2)

        let array1 = t1.array
        let array2 = t2.array
        let array3 = t3.array
        XCTAssertEqual(array1.shape, [2])
        XCTAssertEqual(array2.shape, [2])
        XCTAssertEqual(array3.shape, [2])
        XCTAssertEqual(Double(array1.scalars[0]), 3.6 , accuracy: 0.0001)
        XCTAssertEqual(Double(array1.scalars[1]), 3.6,  accuracy: 0.0001)
        XCTAssertEqual(Double(array2.scalars[0]), 12.96, accuracy: 0.0001)
        XCTAssertEqual(Double(array2.scalars[1]), 12.96, accuracy: 0.0001)
        XCTAssertEqual(Double(array3.scalars[0]), 3.6, accuracy: 0.0001)
        XCTAssertEqual(Double(array3.scalars[1]), 3.6, accuracy: 0.0001)
    }

    func testXWPlusB() {
        // Shape: 1 x 4
        let x = Tensor<Float>([[1.0, 2.0, 2.0, 1.0]])
        // Shape: 4 x 2
        let w = Tensor<Float>([[1.0, 0.0], [3.0, 0.0], [2.0, 3.0], [1.0, 0.0]])
        // Shape: 2
        let b = Tensor<Float>([0.5, 0.5])
        // Shape: 1 x 2 (broadcasted)
        let result = matmul(x, w) + b
        XCTAssertEqual(result.shape, [1, 2])
        XCTAssertEqual(result.scalars, [12.5, 6.5])
    }

    func testXORInference() {
        func xor(_ x: Float, _ y: Float) -> Float {
            let x = Tensor<Float>([x, y]).reshaped(to: [1, 2])

            // FIXME: If params are declared outside of `xor`, it would crash.
            // 2 x 4
            let w1 = Tensor<Float>(
                [[-1.83586664, -0.20809225, 0.47667537, 1.90780607],
                [-1.83523219, -0.51167348, 0.15490439, 1.91018065]])
            // 1 x 4
            let b1 = Tensor<Float>([[2.54353216, 0.25132703, -0.16503136, -0.85754058]])
            // 4 x 1
            let w2 = Tensor<Float>([[3.04350065], [0.35590511], [-0.3252157], [3.49349223]])
            // 1 x 1
            let b2 = Tensor<Float>([[-0.74635993]])

            let o1 = tanh(matmul(x, w1) + b1)
            let y = tanh(matmul(o1, w2) + b2)
            return y.array.scalars[0] // TODO: use better scalar getter
        }

        XCTAssertEqual(xor(0.0, 0.0), 0.0, accuracy: 0.1)
        XCTAssertEqual(xor(0.0, 1.0), 1.0, accuracy: 0.1)
        XCTAssertEqual(xor(1.0, 0.0), 1.0, accuracy: 0.1)
        XCTAssertEqual(xor(1.0, 1.0), 0.0, accuracy: 0.1)
    }

    func testMLPClassifierStruct() {
        struct MLPClassifier {
            // 2 x 4
            var w1 = Tensor<Float>([[1.0, 0.8, 0.4, 0.4],
                                    [0.4, 0.3, 0.2, 0.1]])
            // 4 x 1
            var w2 = Tensor<Float>([[0.4], [0.4], [0.3], [0.9]])
            var b1 = Tensor<Float>(zeros: [1, 4])
            var b2 = Tensor<Float>(zeros: [1, 1])

            func prediction(for x: Tensor<Float>) -> Tensor<Float> {
                let o1 = tanh(matmul(x, w1) + b1)
                return tanh(matmul(o1, w2) + b2)
            }
        }

        let input = Tensor<Float>([[1, 0.5]])
        let classifier = MLPClassifier()
        let prediction = classifier.prediction(for: input)
        XCTAssertEqual(Double(prediction.scalars[0]), 0.816997, accuracy: 0.0001)
    }

    func testQRDecompositionApproximation() {
        let shapes = [[5, 8], [3, 4, 4], [3, 3, 32, 64]]
        for shape in shapes {
            let a = Tensor<Float>(randomNormal: TensorShape(shape))
            let (q, r) = a.qrDecomposition()
            let aReconstituted = matmul(q,r)
            assertEqual(a, aReconstituted, accuracy: 1e-5)

            let (qFull, rFull) = a.qrDecomposition(fullMatrices: true)
            let aReconstitutedFull = matmul(qFull, rFull)
            assertEqual(a, aReconstitutedFull, accuracy: 1e-5)
        }
    }

    func testDiagonalPart() {
        // Test on 2-D matrix.
        let t1 = Tensor<Float>(shape: [4, 4], scalars: (1...16).map(Float.init))
        let target1 = Tensor<Float>([1, 6, 11, 16])
        XCTAssertEqual(target1, t1.diagonalPart())

        // Test on 4-D tensor.
        let t2 = Tensor<Float>([[[[1.0, 0.0, 0.0, 0.0],
                                  [0.0, 0.0, 0.0, 0.0]],
                                 [[0.0, 2.0, 0.0, 0.0],
                                  [0.0, 0.0, 0.0, 0.0]],
                                 [[0.0, 0.0, 3.0, 0.0],
                                  [0.0, 0.0, 0.0, 0.0]],
                                 [[0.0, 0.0, 0.0, 4.0],
                                  [0.0, 0.0, 0.0, 0.0]]],
                                [[[0.0, 0.0, 0.0, 0.0],
                                  [5.0, 0.0, 0.0, 0.0]],
                                 [[0.0, 0.0, 0.0, 0.0],
                                  [0.0, 6.0, 0.0, 0.0]],
                                 [[0.0, 0.0, 0.0, 0.0],
                                  [0.0, 0.0, 7.0, 0.0]],
                                 [[0.0, 0.0, 0.0, 0.0],
                                  [0.0, 0.0, 0.0, 8.0]]]])
        let target2 = Tensor<Float>([[1, 2, 3, 4], [5, 6, 7, 8]])
        XCTAssertEqual(target2, t2.diagonalPart())
    }

    func testBroadcastedAddGradient() {
        func foo(_ x: Tensor<Float>, _ y: Tensor<Float>) -> Tensor<Float> {
            return (x + y).sum()
        }
        let x = Tensor<Float>(ones: [1, 2, 1, 4])
        let y = Tensor<Float>(ones: [4, 1, 3, 1])
        let (dx, dy) = gradient(at: x, y, in: foo)
        XCTAssertEqual(x.shape, dx.shape)
        XCTAssertEqual(y.shape, dy.shape)
    }

    static var allTests = [
        ("testElementaryFunctions", testElementaryFunctions),
        ("testLog1p", testLog1p),
        ("testLog1mexp", testLog1mexp),
        ("testExpm1", testExpm1),
        ("testSign", testSign),
        ("testLogSigmoid", testLogSigmoid),
        ("testSoftplus", testSoftplus),
        ("testSoftsign", testSoftsign),
        ("testElu",testElu),
        ("testGelu", testGelu),
        ("testLeakyRelu", testLeakyRelu),
        ("testIsFinite", testIsFinite),
        ("testIsInfinite", testIsInfinite),
        ("testIsNaN", testIsNaN),
        ("testCosineSimilarity", testCosineSimilarity),
        ("testReduction", testReduction),
        ("testArgmax", testArgmax),
        ("testLogSumExp", testLogSumExp),
        ("testCeilAndFloor", testCeilAndFloor),
        ("testSimpleMath", testSimpleMath),
        ("testStandardDeviation", testStandardDeviation),
        ("test3Adds", test3Adds),
        ("testMultiOpMath", testMultiOpMath),
        ("testXWPlusB", testXWPlusB),
        ("testXORInference", testXORInference),
        ("testMLPClassifierStruct", testMLPClassifierStruct),
        ("testQRDecompositionApproximation", testQRDecompositionApproximation),
        ("testDiagonalPart", testDiagonalPart),
        ("testBroadcastedAddGradient", testBroadcastedAddGradient)
    ]
}
