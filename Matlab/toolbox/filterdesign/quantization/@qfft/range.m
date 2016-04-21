function varargout = range(F,varargin)
%RANGE  Numerical range of the quantizers in a quantized FFT.
%   RANGE(F) displays the ranges of all the quantizers in quantized FFT
%   object F.
%
%   R = RANGE(F,T) returns the range associated with the quantizer specified by
%   string T where T is one of 'coefficient', 'input', 'output', 'multiplicand',
%   'product', 'sum'. 
%
%   [R1,R2,...] = RANGE(F,T1,T2,...) returns the ranges
%   associated with the quantizers associated with T1, ....
%
%   [RTWIDDLE, RINPUT, ROUTPUT, RMULTIPLICAND, RPRODUCT, RSUM] = RANGE(F) returns
%   the ranges associated with the coefficient, input, output, multiplicand,
%   product, and sum quantizers, respectively. 
%
%   If the MATLAB workspace display format is HEX, then the ranges are
%   displayed in hexadecimal format.
%
%   If the MATLAB workspace display format is RAT, then the ranges are
%   displayed in rational format.
%
%   Example:
%     F = qfft;
%     format hex
%     range(F)
%
%     format rat
%     range(F)
%
%     format
%     range(F)
%
%   See also QFFT, QUANTIZER, UNITQUANTIZER, QUANTIZER/RANGE.

%   Thomas A. Bryan, 1 July 1999
%   Copyright 1999-2002 The MathWorks, Inc.
%   $Revision: 1.13 $  $Date: 2002/04/14 15:26:19 $


[varargout{1:nargout}] = qformat(F,'range',varargin{:});
