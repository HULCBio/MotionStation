function this = fimath(varargin)
%FIMATH  Constructor for FIMATH object.
%   F = FIMATH constructs a fixed-point math object.
%
%   F = FIMATH('PropertyName1',PropertyValue1,...) constructs a
%   fixed-point math object with the named properties set to their
%   corresponding values.
%
%   FIMATH properties:
%     CastBeforeSum          - Cast both operands in A+B to the sum type before addition.
%     MaxProductWordLength   - Maximum word length for products.  Can be set from 2 to 65535.
%     MaxSumWordLength       - Maximum word length for sums.  Can be set from 2 to 65535.
%     OverflowMode           - Overflow mode: {Saturate, Wrap}
%     ProductFractionLength  - Product length when ProductMode is SpecifyPrecision.
%     ProductMode            - Product mode: {FullPrecision, KeepLSB, KeepMSB, SpecifyPrecision}.
%     ProductWordLength      - Product word length when ProductMode is one of KeepLSB, KeepMSB, or SpecifyPrecision.
%     RoundMode              - Round mode: {ceil, convergent, fix, floor, round}
%     SumFractionLength      - Sum fraction length, when ProductMode is SpecifyPrecision.
%     SumMode                - Sum mode: {FullPrecision, KeepLSB, KeepMSB, SpecifyPrecision}.
%     SumWordLength          - Sum word length when ProductMode is one of KeepLSB, KeepMSB, or SpecifyPrecision.
%
%   Example:
%     F = fimath
%     F.RoundMode     = 'floor'
%     F.OverFlowMode  = 'wrap'
%     F.SumMode       = 'KeepLSB'
%     F.SumWordLength = 40
%     F.CastBeforeSum = false
%
%   See also FI, FIPREF, NUMERICTYPE, QUANTIZER, SAVEFIPREF, FIXEDPOINT.

%   Thomas A. Bryan, 5 April 2004
%   Copyright 2003-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2004/04/20 23:18:38 $

registerembedded;
n1=0;
if nargin > 0 && isfimath(varargin{1})
  this = varargin{1};
  n1=n1+1;
else
  this = embedded.fimath;
end
n2 = nargin - n1;
if fi(n2/2)~=n2/2
  error('Invalid parameter/value pair arguments.');
end
for k=(n1+1):2:n2
  this.(varargin{k}) = varargin{k+1};
end
    


