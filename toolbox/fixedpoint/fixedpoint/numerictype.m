function this = numerictype(varargin)
%NUMERICTYPE  Numeric-type object.
%   T = NUMERICTYPE creates a NUMERICTYPE object, which encapsulates
%   numeric type information.
% 
%   T = NUMERICTYPE(Parameter1,Value1, ...) creates a NUMERICTYPE object
%   with specified parameter/values.
%
%   The properties and values can be set using the dot notation also:
%     T = NUMERICTYPE;
%     T.PropertyName = Value
%     Value = T.PropertyName
%   For example,
%     T = numerictype
%     T.WordLength = 80
%     w = T.WordLength
%
%   T2 = NUMERICTYPE(T, Parameter1,Value1, ...) copies NUMERICTYPE
%   object T to T2, and sets T2's parameter/value pairs.
%
%   
%   The parameters and values are as follows (defaults are set apart by <>)
%
%              DataTypeMode: {<'Fixed-point: binary point scaling',>
%                             'Fixed-point: slope and bias scaling',
%                             'Fixed-point: unspecified scaling',
%                             'boolean',
%                             'double',
%                             'single',
%                             'int8',
%                             'int16',
%                             'int32',
%                             'uint8',
%                             'uint16',
%                             'uint32'}
%                  DataType: {<'Fixed'>,
%                             'boolean',
%                             'double',
%                             'single'}
%                   Scaling: {<'BinaryPoint'>,
%                             'SlopeBias',
%                             'Unspecified'}
%                    Signed: {<true>, false}
%                WordLength: Positive integer, <16>
%            FractionLength: Integer = -FixedExponent, <15>
%             FixedExponent: Integer = -FractionLength, <-15>
%                     Slope: Double, <2^-15>
%     SlopeAdjustmentFactor: Double, <1>
%                      Bias: Double, <0>
%
%   Only fixed-point and integer numeric types are allowed in FI objects.
%
%   Fixed-point numbers are specified by one of
%
%   (1) If 
%         DataTypeMode='Fixed-point: binary point scaling'
%         (equivalently, DataType='Fixed', Scaling='BinaryPoint')
%       then
%          Real-world value = (-1)^Signed * 2^(-FractionLength)  * (Stored Integer).
%           
%   (2) If
%         DataTypeMode='Fixed-point: slope and bias scaling'
%         (equivalently, DataType='Fixed', Scaling='SlopeBias')
%       then
%         Real-world value = (-1)^Signed * SlopeAdjustmentFactor * 2^FixedExponent * (Stored Integer) + Bias.
%       The Slope is defined by
%         Slope = SlopeAdjustmentFactor * 2^FixedExponent
%
%
%   Examples:
%
%     T1 = numerictype
%     T2 = numerictype('WordLength',80,'FractionLength',40)
%     T3 = numerictype('Scaling','SlopeBias','SlopeAdjustmentFactor',0.1,'Bias',10)
%
%     T4 = numerictype
%     T4.WordLength = 80
%     T4.FractionLength = 40
%
%     T5 = numerictype(T4, 'FractionLength', 50)
%
%   See also FI, FIMATH, FIPREF, QUANTIZER, SAVEFIPREF, FORMAT, FIXEDPOINT.

%   Thomas A. Bryan, 5 April 2004
%   Copyright 2003-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2004/04/20 23:18:40 $

registerembedded;
n1=0;
if nargin > 0 && isnumerictype(varargin{1})
  this = varargin{1};
  n1=n1+1;
else
  this = embedded.numerictype;
end
n2 = nargin - n1;
if fi(n2/2)~=n2/2
  error('Invalid parameter/value pair arguments.');
end
for k=(n1+1):2:n2
  this.(varargin{k}) = varargin{k+1};
end
    

