% Symbolic Math Toolbox
% Version 3.1 (R14) 05-May-2004
%
% Calculus.
%   diff        - Differentiate.
%   int         - Integrate.
%   limit       - Limit.
%   taylor      - Taylor series.
%   jacobian    - Jacobian matrix.
%   symsum      - Summation of series. 
%
% Linear Algebra.
%   diag        - Create or extract diagonals.
%   triu        - Upper triangle.
%   tril        - Lower triangle.
%   inv         - Matrix inverse.
%   det         - Determinant.
%   rank        - Rank.
%   rref        - Reduced row echelon form.
%   null        - Basis for null space.
%   colspace    - Basis for column space.
%   eig         - Eigenvalues and eigenvectors.
%   svd         - Singular values and singular vectors.
%   jordan      - Jordan canonical (normal) form.
%   poly        - Characteristic polynomial.
%   expm        - Matrix exponential.
%   mldivide    - \  matrix left division.
%   mpower      - ^  matrix power.
%   mrdivide    - /  matrix right division.
%   mtimes      - *  matrix multiplication.
%   transpose   - .' matrix transpose.
%   ctranspose  - '  matrix complex conjugate transpose.
%
% Simplification.
%   simplify    - Simplify.
%   expand      - Expand.
%   factor      - Factor.
%   collect     - Collect.
%   simple      - Search for shortest form.
%   numden      - Numerator and denominator.
%   horner      - Nested polynomial representation.
%   subexpr     - Rewrite in terms of subexpressions.
%   coeffs      - Coefficients of a multivariate polynomial.
%   sort        - Sort symbolic vectors or polynomials.
%   subs        - Symbolic substitution.
%
% Solution of Equations.
%   solve       - Symbolic solution of algebraic equations.
%   dsolve      - Symbolic solution of differential equations.
%   finverse    - Functional inverse.
%   compose     - Functional composition.
%
% Variable Precision Arithmetic.
%   vpa         - Variable precision arithmetic.
%   digits      - Set variable precision accuracy.
%
% Integral Transforms.
%   fourier     - Fourier transform.
%   laplace     - Laplace transform.
%   ztrans      - Z transform.
%   ifourier    - Inverse Fourier transform.
%   ilaplace    - Inverse Laplace transform.
%   iztrans     - Inverse Z transform.
%
% Conversions.
%   double      - Convert symbolic matrix to double.
%   single      - Convert symbolic matrix to single precision.
%   poly2sym    - Coefficient vector to symbolic polynomial.
%   sym2poly    - Symbolic polynomial to coefficient vector.
%   char        - Convert sym object to string.
%   int8        - Convert to signed 8-bit integers.
%   int16       - Convert to signed 16-bit integers.
%   int32       - Convert to signed 32-bit integers.
%   int64       - Convert to signed 64-bit integers.
%   uint8       - Convert to unsigned 8-bit integers.
%   uint16      - Convert to unsigned 16-bit integers.
%   uint32      - Convert to unsigned 32-bit integers.
%   uint64      - Convert to unsigned 64-bit integers.
%
% Symbolic Operations.
%   sym         - Create symbolic object.
%   syms        - Short-cut for constructing symbolic objects.
%   findsym     - Determine symbolic variables.
%   pretty      - Pretty print a symbolic expression.
%   latex       - LaTeX representation of a symbolic expression.
%   texlabel    - Produces the TeX format from a character string.
%   ccode       - C code representation of a symbolic expression.
%   fortran     - FORTRAN representation of a symbolic expression.
%
% Arithmetic and Algebraic Operations.
%   plus        - +  addition.
%   minus       - -  subtraction.
%   uminus      - -  negation.
%   times       - .* array multiplication.
%   ldivide     - \  left division.
%   rdivide     - /  right division.
%   power       - .^ array power.
%   abs         - Absolute value.
%   ceil        - Ceiling.
%   conj        - Conjugate.
%   colon       - Colon operator.
%   fix         - Integer part.
%   floor       - Floor.
%   frac        - Fractional part.
%   mod         - Mod.
%   round       - Round.
%   quorem      - Quotient and remainder.
%   imag        - Imaginary part.
%   real        - real part.
%   exp         - Exponential.
%   log         - Natural logarithm.
%   log10       - Common logarithm.
%   log2        - Base-2 logarithm.
%   sqrt        - Square root.
%   prod        - Product of the elements.
%   sum         - Sum of the elements.
%
% Logical Operations.
%   isreal      - True for real array
%   eq          - Equality test.
%   ne          - Inequality test.
%
% Special Functions.
%   besseli     - Bessel function, I.
%   besselj     - Bessel function, J.
%   besselk     - Bessel function, K.
%   bessely     - Bessel function, Y.
%   erf         - Error function.
%   sinint      - Sine integral.
%   cosint      - Cosine integral.
%   zeta        - Riemann zeta function.
%   gamma       - Symbolic gamma function.
%   gcd         - Greatest common divisor.
%   lcm         - Least common multiple.
%   hypergeom   - Generalized hypergeometric function.
%   lambertw    - Lambert W function.
%   dirac       - Delta function.
%   heaviside   - Step function.
%
% Trigonometric Functions. 
%
%   acos        - Inverse cosine.
%   acosh       - Inverse hyperbolic cosine.
%   acot        - Inverse cotangent.
%   acoth       - Inverse hyperbolic cotangent.
%   acsc        - Inverse cosecant.
%   acsch       - Inverse hyperbolic cosecant.
%   asec        - Inverse secant.
%   asech       - Inverse hyperbolic secant.
%   asin        - Inverse sine.
%   asinh       - Inverse hyperbolic sine.
%   atan        - Inverse tangent.
%   atanh       - Inverse hyperbolic tangent.
%   cos         - Cosine function.
%   cosh        - Hyperbolic cosine.
%   cot         - Cotangent.
%   coth        - Hyperbolic cotangent.
%   csc         - Cosecant.
%   csch        - Hyperbolic cosecant.
%   sec         - Secant.
%   sech        - Hyperbolic sechant.
%   sin         - Sine function.
%   sinh        - Hyperbolic sine.
%   tan         - Tangent function.
%   tanh        - Hyperbolic tangent.
%
% String handling utilities.
%   isvarname   - Check for a valid variable name (MATLAB Toolbox).
%   vectorize   - Vectorize a symbolic expression.
%   disp        - Displays a sym as text.
%   display     - Display function for syms.
%   eval        - Evaluate a symbolic expression.
%
% Pedagogical and Graphical Applications.
%   rsums       - Riemann sums.
%   ezcontour   - Easy to use contour plotter.
%   ezcontourf  - Easy to use filled contour plotter.
%   ezmesh      - Easy to use mesh (surface) plotter.
%   ezmeshc     - Easy to use combined mesh/contour plotter.
%   ezplot      - Easy to use function, implicit, and parametric curve plotter.
%   ezplot3     - Easy to use spatial curve plotter.
%   ezpolar     - Easy to use polar coordinates plotter.
%   ezsurf      - Easy to use surface plotter.
%   ezsurfc     - Easy to use combined surface/contour plotter.
%   funtool     - Function calculator.
%   taylortool  - Taylor series calculator.
%
% Demonstrations.
%   symintro    - Introduction to the Symbolic Toolbox.
%   symcalcdemo - Calculus demonstration.
%   symlindemo  - Demonstrate symbolic linear algebra.
%   symvpademo  - Demonstrate variable precision arithmetic
%   symrotdemo  - Study plane rotations.
%   symeqndemo  - Demonstrate symbolic equation solving.
%
% Access to Maple. (Not available with Student Version.)
%   maple       - Access Maple kernel.
%   mfun        - Numeric evaluation of Maple functions.
%   mfunlist    - List of functions for MFUN.
%   mhelp       - Maple help.
%   procread    - Install a Maple procedure. (Requires Extended Toolbox.)

%   Copyright 1993-2004 The MathWorks, Inc. 
%   Generated from Contents.m_template revision 1.1.6.2  $Date: 2003/11/24 23:24:22 $
