function F = qfft(varargin)
%QFFT   Constructor for quantized FFT object.
%   F = QFFT constructs a quantized FFT object with default values.
%
%   F = QFFT('Property1',Value1, 'Property2',Value2, ...) creates a quantized
%   FFT object with property/value pairs.
%
%   F = QFFT(a) where a is a structure whose field names are object property
%   names, sets the properties named in each field name with the values
%   contained in the structure.
%  
%   F = QFFT(pn,pv) sets the named properties specified in the cell array of
%   strings pn to the corresponding values in the cell array pv.
%
%   Property/Value pairs with defaults in angled brackets.
%
%               Radix = <2> | 4
%              Length = <16>  (Scalar, a power of the radix)
%   CoefficientFormat = <quantizer> | unitquantizer
%         InputFormat = <quantizer> | unitquantizer
%        OutputFormat = <quantizer> | unitquantizer
%  MultiplicandFormat = <quantizer> | unitquantizer
%       ProductFormat = <quantizer> | unitquantizer
%           SumFormat = <quantizer> | unitquantizer
%         ScaleValues = <1> (Scalar, one per section)
%  
%   For more information about individual properties, do 
%     HELP QFFT/<PROPERTYNAME> 
%   or
%     HELPWIN QFFT/<PROPERTYNAME>
%   where <PROPERTYNAME> is the name of one of the properties. 
%
%   Examples:
%     help qfft/length
%     F = qfft('length',64)
%
%   See also FILTERDESIGN, QFFT/FFT, QFFT/IFFT, QFFT/GET, QFFT/SET,
%   QFFT/RADIX, QFFT/LENGTH, QFFT/COEFFICIENTFORMAT, QFFT/INPUTFORMAT,
%   QFFT/OUTPUTFORMAT, QFFT/MULTIPLICANDFORMAT, QFFT/PRODUCTFORMAT,
%   QFFT/SUMFORMAT, QFFT/SCALEVALUES, QUANTIZER, UNITQUANTIZER.

%   Thomas A. Bryan, 28 June 1999
%   Copyright 1999-2002 The MathWorks, Inc.
%   $Revision: 1.19 $  $Date: 2002/04/14 15:26:28 $

F = struct(...
    'radix', 2, ...
    'length', 16, ...
    'coefficientformat', quantizer('fixed','saturate','round',[16 15]), ...
    'inputformat', quantizer('fixed','saturate','floor',[16 15]), ...
    'outputformat', quantizer('fixed','saturate','floor',[16 15]), ...
    'multiplicandformat', quantizer('fixed','saturate','floor',[16 15]), ...
    'productformat', quantizer('fixed','saturate','floor',[32 30]), ...
    'sumformat', quantizer('fixed','saturate','floor',[32 30]), ...
    'scalevalues', 1, ...
    'version', qfftversion);
  
F = class(F, 'qfft');
  
if nargin > 0
  F = set(F, varargin{:});
end

