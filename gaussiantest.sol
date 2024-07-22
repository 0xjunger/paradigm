// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/GaussianCDF.sol";

contract GaussianCDFTest is Test {
    GaussianCDF private gaussianCDF;

    function setUp() public {
        gaussianCDF = new GaussianCDF();
    }

    function testGaussianCDF() public {
        // Test cases: [x, mu, sigma, expected result]
        int256[4][10] memory testCases = [
            [0 * 1e18, 0 * 1e18, 1 * 1e18, 5000000000000000000],  // 0.5
            [1 * 1e18, 0 * 1e18, 1 * 1e18, 8413447460685429720],  // ~0.8413
            [-1 * 1e18, 0 * 1e18, 1 * 1e18, 1586552539314570280], // ~0.1587
            [2 * 1e18, 0 * 1e18, 1 * 1e18, 9772498680518208900],  // ~0.9772
            [0 * 1e18, 1 * 1e18, 2 * 1e18, 3085375387259869140],  // ~0.3085
            [-3 * 1e18, -1 * 1e18, 1 * 1e18, 22750131948179100],   // ~0.0228
            [1e23, 0 * 1e18, 1e19, 1000000000000000000],          // ~1.0
            [-1e23, 0 * 1e18, 1e19, 0],                           // ~0.0
            [5 * 1e18, 2 * 1e18, 3 * 1e18, 8413447460685429720],  // ~0.8413
            [-1e20, 1e20, 1e19, 0]                                // ~0.0
        ];

        for (uint i = 0; i < testCases.length; i++) {
            int256 result = gaussianCDF.gaussianCDF(testCases[i][0], testCases[i][1], testCases[i][2]);
            int256 expectedResult = testCases[i][3];
            
            assertApproxEqAbs(result, expectedResult, 1e10, "GaussianCDF result mismatch");
        }
    }

    function testInvalidInputs() public {
        // Test invalid sigma
        vm.expectRevert("Invalid sigma");
        gaussianCDF.gaussianCDF(0, 0, 0);

        vm.expectRevert("Invalid sigma");
        gaussianCDF.gaussianCDF(0, 0, 1e20);

        // Test invalid mu
        vm.expectRevert("Invalid mu");
        gaussianCDF.gaussianCDF(0, -1e20 - 1, 1e18);

        vm.expectRevert("Invalid mu");
        gaussianCDF.gaussianCDF(0, 1e20 + 1, 1e18);
    }

    function testFuzzGaussianCDF(int256 x, int256 mu, int256 sigma) public {
        // Bound inputs to valid ranges
        x = bound(x, -1e23, 1e23);
        mu = bound(mu, -1e20, 1e20);
        sigma = bound(sigma, 1, 1e19);

        int256 result = gaussianCDF.gaussianCDF(x, mu, sigma);

        // Basic sanity checks
        assertTrue(result >= 0 && result <= 1e18, "Result out of range");

        if (x < mu) {
            assertTrue(result < 5e17, "Result should be less than 0.5 for x < mu");
        } else if (x > mu) {
            assertTrue(result > 5e17, "Result should be greater than 0.5 for x > mu");
        } else {
            assertApproxEqAbs(result, 5e17, 1e10, "Result should be close to 0.5 for x == mu");
        }
    }
}
