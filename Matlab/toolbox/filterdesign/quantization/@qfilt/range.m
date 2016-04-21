function varargout = range(Hq,varargin)
%RANGE  Numerical range of the quantizers in a QFILT object.
%   RANGE(Hq) displays the ranges of all the quantizers in QFILT object
%   object Hq.
%
%   R = RANGE(Hq,FORMATTYPE) returns the range associated with the
%   quantizer specified by FORMATTYPE.  FORMATTYPE is a string, one of
%   'coefficient', 'input', 'output', 'multiplicand', 'product', 'sum'.
%
%   [R1,R2,...] = RANGE(Hq,FORMATTYPE1,FORMATTYPE2,...) returns the
%   ranges associated with the quantizers associated with FORMATTYPE1,
%   FORMATTYPE2, ....
%
%   [RCOEFFICIENT, RINPUT, ROUTPUT, RMULTIPLICAND, RPRODUCT, RSUM] =
%   RANGE(F) returns the ranges associated with the coefficient, input,
%   output, multiplicand, product, and sum quantizers, respectively.
%
%   If the MATLAB workspace display format is HEX, then the ranges are
%   displayed in hexadecimal format.
%
%   If the MATLAB workspace display format is RAT, then the ranges are
%   displayed in rational format.
%
%   Example:
%     Hq = qfilt;
%     format hex
%     range(Hq)
%
%     format rat
%     range(Hq)
%
%     format
%     range(Hq)
%
%   See also QFILT, QFILT/EPS, QUANTIZER, QUANTIZER/RANGE.

%   Thomas A. Bryan, 2 July 1999
%   Copyright 1999-2002 The MathWorks, Inc.
%   $Revision: 1.14 $  $Date: 2002/04/14 15:30:10 $

[varargout{1:nargout}] = qformat(Hq,'range',varargin{:});
