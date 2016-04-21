function A = sim2fi(IntArray, varargin)
%SIM2FI  Simulink integer array to FI object.
%   A = SIM2FI(IntArray, NumericType)
%   A = SIM2FI(IntArray, Signed, WordLength, FractionLength)
%   A = SIM2FI(IntArray, Signed, WordLength, Slope, Bias)
%   A = SIM2FI(IntArray, Signed, WordLength, SlopeAdjustmentFactor, FixedExponent, Bias)
%
%   Returns FI object A with the stored-integer data from integer array
%   IntArray and the given numeric type attributes.
%
%   SIM2FI is the inverse of FI2SIM.
%
%   See also FI, FIMATH, FIPREF, NUMERICTYPE, QUANTIZER, SAVEFIPREF, FIXEDPOINT.

%   Thomas A. Bryan, 5 April 2004
%   Copyright 2003-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2004/04/20 23:18:43 $

error(nargchk(2,6,nargin,'struct'));



switch nargin
  case 2
    % A = SIM2FI(IntArray, NumericType)
    T = varargin{1};
    if ~isnumerictype(T)
      error(['Calling SIM2FI with 2 input arguments, the second argument ' ...
             'must be a NUMERICTYPE object.']);
    end
  case 3
    error(['SIM2FI must have 2, 4, or 5 input arguments. You have ' ...
           'entered 3.']);
  case 4
    % A = SIM2FI(IntArray, Signed, WordLength, FractionLength)
    T = numerictype;
    T.DataType        = 'fixed';
    T.Scaling         = 'BinaryPoint';
    T.Signed          = varargin{1};
    T.WordLength      = varargin{2};
    T.FractionLength  = varargin{3};
  case 5
    % A = SIM2FI(IntArray, Signed, WordLength, Slope, Bias)
    T = numerictype;
    T.DataType        = 'fixed';
    T.Scaling         = 'SlopeBias';
    T.Signed          = varargin{1};
    T.WordLength      = varargin{2};
    T.Slope           = varargin{3};
    T.Bias            = varargin{4};
  case 6
    % A = SIM2FI(IntArray, Signed, WordLength, SlopeAdjustmentFactor, FixedExponent, Bias)
    T = numerictype;
    T.DataType        = 'fixed';
    T.Scaling         = 'SlopeBias';
    T.Signed          = varargin{1};
    T.WordLength      = varargin{2};
    T.SlopeAdjustmentFactor = varargin{3};
    T.FixedExponent   = varargin{4};
    T.Bias            = varargin{5};
end

if T.WordLength > 128
  error(['Simulink fixed-point data types must have word lengths less ' ...
         'than or equal to 128 bits.']);
end

A = fi(0,T);
A.simulinkarray = IntArray;