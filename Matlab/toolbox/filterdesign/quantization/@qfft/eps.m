function varargout = eps(F,varargin)
%EPS  Relative accuracy of the quantizers in a QFFT object.
%   EPS(F) displays the eps of all the quantizers in QFFT object
%   object F.
%
%   E = EPS(F,FORMATTYPE) returns the eps associated with the quantizer
%   specified by FORMATTYPE.  FORMATTYPE is a string, one of
%   'coefficient', 'input', 'output', 'multiplicand', 'product', 'sum'.
%
%   [E1,E2,...] = EPS(F,FORMATTYPE1,FORMATTYPE2,...) returns the eps
%   associated with the quantizers associated with FORMATTYPE1, ....
%
%   [ECOEFFICIENT, EINPUT, EMULTIPLICAND, EOUTPUT, EPRODUCT, ESUM] =
%   EPS(F) returns the eps associated with the coefficient, input,
%   output, multiplicand, product, and sum quantizers, respectively.
%
%   If the MATLAB workspace display format is HEX, then the eps are
%   displayed in hexadecimal format.
%
%   If the MATLAB workspace display format is RAT, then the eps are
%   displayed in rational format.
%
%   Example:
%     F = qfft;
%     format hex
%     eps(F)
%
%     format rat
%     eps(F)
%
%     format
%     eps(F)
%
%   See also QFFT.

%   Thomas A. Bryan, 29 September 1999
%   Copyright 1999-2002 The MathWorks, Inc.
%   $Revision: 1.7 $  $Date: 2002/04/14 15:26:52 $

[varargout{1:nargout}] = qformat(F,'eps',varargin{:});
