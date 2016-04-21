% Fixed-Point Toolbox
% Version 1.0 (R14) 05-May-2004
%
% Fixed-Point Objects.
%   fi               - Fixed-point object constructor.
%   fimath           - Fixed-point math object constructor.
%   numerictype      - Numeric type object constructor.
%
% Display preferences.
%   fipref           - Fixed-point display preferences.
%   savefipref       - Save fixed-point display preferences.
%
% NUMERICTYPE properties of fi.
%   Bias
%   BinaryPoint
%   DataType
%   DataTypeMode
%   FixedExponent
%   FractionLength
%   Scaling
%   Signed
%   Slope
%   SlopeAdjustmentFactor
%   WordLength
%
% FIMATH properties of fi.
%   CastBeforeSum
%   MaxProductWordLength
%   MaxSumWordLength
%   OverflowMode
%   ProductFractionLength
%   ProductMode
%   ProductWordLength
%   RoundMode
%   SumFractionLength
%   SumMode
%   SumWordLength
%
% Data access properties of fi.  In the following, let A=fi(pi);
%   double           - A.double = 3.1416015625 sets A's real-world-value from the double value.
%   int              - A.int    = 25736 sets A's stored integer from the integer.
%
%   bin              - A.bin = '0110010010001000' sets A's stored integer from the binary string.
%   oct              - A.oct = '062210' sets A's stored integer from the octal string.
%   dec              - A.dec = '25736' sets A's stored integer from the decimal string.
%   hex              - A.hex = '6488' sets A's stored integer from the hex string.
%
%
% Functions that work with fi objects.
%   bin              - Binary representation.
%   bitand           - Bit-wise AND.
%   bitcmp           - Complement bits.
%   bitget           - Get bit.
%   bitor            - Bit-wise OR.
%   bitset           - Set bit.
%   bitshift         - Bit-wise shift.
%   bitxor           - Bit-wise XOR.
%   complex          - Construct complex result from real and imaginary parts.
%   conj             - Complex conjugate.
%   ctranspose       - Complex conjugate transpose: called for A'
%   data             - Closest real-world-value that can be represented as a double.
%   dec              - Decimal integer string representation of stored integer.
%   disp             - Display without printing the variable name.
%   display          - Display with printing the variable name.
%   double           - Closest real-world-value that can be represented as a double.
%   eps              - Scaling of the least-significant bit.
%   eq               - Equal: called for A==B.
%   fi               - Constructs a fi object.
%   fieldnames       - Get object's field names.
%   fimath           - Get fimath object associated with this fi.
%   ge               - Greater than or equal: called for A >= B.
%   gt               - Greater than: called for A > B.
%   hex              - Hex representation of the stored integer.
%   horzcat          - Horizontal concatenation: called for [A B].
%   imag             - Complex imaginary part.
%   int              - Stored integer value as MATLAB native integer.
%   int8             - Stored integer value cast to int8.
%   int16            - Stored integer value cast to int16.
%   int32            - Stored integer value cast to int32.
%   intmax           - Largest stored integer value.
%   intmin           - Smallest stored integer value. 
%   iscolumn         - True if array is a column vector.
%   isempty          - True if empty.
%   isequal          - True arrays are numerically equal.
%   isfi             - True if fi object.
%   isnumeric        - True for numeric arrays.  fi objects are considered numeric arrays.
%   ispropequal      - True if arrays are numerically equal and all properties are equal.
%   isreal           - True if array does not have an imaginary part.
%   isrow            - True if array is a row vector.
%   isscalar         - True if array is a scalar.
%   issigned         - True if the Signed property is true.
%   isvector         - True if array is a vector (either row or column).
%   le               - Less than or equal: called for A <= B.
%   length           - Length of vector, or max dimension.
%   loglog           - Log-log scale plot.
%   lowerbound       - Least value representable.
%   lsb              - Scale of the least-significant-bit.
%   lt               - Less than: called for A < B.
%   max              - Largest component.
%   min              - Smallest component.
%   minus            - Minus: called for A - B.
%   mtimes           - Matrix multiply: called for A * B.
%   ndims            - Number of dimensions.
%   ne               - Not equal: called for A ~= B.
%   numberofelements - Number of elements in array.
%   numerictype      - Get numerictype object associated with this fi.
%   oct              - Octal representation of the stored integer.
%   permute          - Permute array dimensions.
%   plot             - Linear plot.
%   plus             - Plus: called for A + B.
%   range            - Numerical range.
%   real             - Complex real part.
%   realmax          - Greatest representable value.
%   realmin          - Smallest positive value representable.
%   repmat           - Replicate and tile array.
%   rescale          - Change the scaling of a fi, while keeping its stored integer value.
%   reshape          - Change shape of an array.
%   semilogx         - Semi-log scale plot.
%   semilogy         - Semi-log scale plot.
%   shiftdata        - Shift data to operate on a specified dimension.
%   size             - Size of array.
%   squeeze          - Remove singleton dimensions.
%   stripscaling     - Strip scaling information from fi.
%   subsasgn         - Subscripted assignment: called for A(k) = B.
%   subsref          - Subscripted reference: called for A = B(k).
%   times            - Array multiply: called for A .* B
%   transpose        - Transpose: called for A.'
%   uint8            - Stored integer value cast to int8. 
%   uint16           - Stored integer value cast to int16.
%   uint32           - Stored integer value cast to int32.
%   uminus           - Unary minus: called for -A
%   unshiftdata      - The inverse of shiftdata.
%   uplus            - Unary plus: called for +A.
%   upperbound       - Greatest representable value.
%   vertcat          - Vertical concatenation: called for [A;B]

%   Copyright 2003-2004 The MathWorks, Inc.
%   Generated from Contents.m_template revision 1.1.6.1 $Date: 2004/04/08 20:51:11 $
