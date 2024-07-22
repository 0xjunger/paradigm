// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract GaussianCDF {
    // Constants
    int256 private constant ONE = 1e18;
    int256 private constant SQRT_2PI = 2506628274631000502; // sqrt(2*pi) * 1e18
    int256 private constant MAGIC_CONST1 = 726728799102949567; // 0.7265629910294956 * 1e18
    int256 private constant MAGIC_CONST2 = 452929354753926632; // 0.4529293547539266 * 1e18

    // Main function to calculate Gaussian CDF
    function gaussianCDF(int256 x, int256 mu, int256 sigma) public pure returns (int256) {
        require(sigma > 0 && sigma <= 1e19, "Invalid sigma");
        require(mu >= -1e20 && mu <= 1e20, "Invalid mu");

        x = (x - mu) * ONE / sigma;
        
        if (x < 0) {
            return ONE - _gaussianCDFPositive(-x);
        } else {
            return _gaussianCDFPositive(x);
        }
    }

    // Helper function for positive x
    function _gaussianCDFPositive(int256 x) private pure returns (int256) {
        if (x >= 8372016954 /* 8.372016954 * 1e9 */) {
            return ONE;
        }

        int256 t = ONE / (ONE + MAGIC_CONST1 * x / ONE);
        int256 t2 = (t * t) / ONE;
        int256 t3 = (t2 * t) / ONE;
        int256 t4 = (t3 * t) / ONE;
        int256 t5 = (t4 * t) / ONE;

        int256 polynomialSum = 330274315; // 0.330274315 * 1e9
        polynomialSum = polynomialSum * t / ONE - 3564723645; // -3.564723645 * 1e9
        polynomialSum = polynomialSum * t / ONE + 17596476030; // 17.596476030 * 1e9
        polynomialSum = polynomialSum * t / ONE - 45629070163; // -45.629070163 * 1e9
        polynomialSum = polynomialSum * t / ONE + 66807200952; // 66.807200952 * 1e9
        polynomialSum = polynomialSum * t / ONE - 58592997739; // -58.592997739 * 1e9
        polynomialSum = polynomialSum * t / ONE + 31253192551; // 31.253192551 * 1e9

        int256 expTerm = exp(-x * x / (2 * ONE));
        int256 result = ONE - (expTerm * polynomialSum) / (SQRT_2PI * 1e9);

        return result;
    }

    // Optimized fixed-point exponential function
    function exp(int256 x) private pure returns (int256) {
        require(x <= 130e18, "Exp overflow");

        if (x < -41e18) return 0;

        int256 k = (x * 1e18) / 405465108108164381; // ln(2) * 1e18
        int256 z = x - k * 405465108108164381 / 1e18;
        int256 y = 1e18 + z + (z * z) / 2e18 + (z * z * z) / 6e18 + (z * z * z * z) / 24e18;

        int256 result = y;
        if (k >= 0) {
            for (int256 i = 0; i < k; i++) {
                result = (result * 2) / 1e18;
            }
        } else {
            for (int256 i = 0; i > k; i--) {
                result = (result * 1e18) / 2;
            }
        }

        return result;
    }
}
