function varargout = eps(Hq,varargin)
%EPS  Relative accuracy of the quantizers in a QFILT object.
%   EPS(Hq) displays the eps of all the quantizers in QFILT object
%   object Hq.
%
%   E = EPS(Hq,FORMATTYPE) returns the eps associated with the quantizer
%   specified by FORMATTYPE.  FORMATTYPE is a string, one of 'coefficient',
%   'input', 'output', 'multiplicand', 'product', 'sum'.
%
%   [E1,E2,...] = EPS(Hq,FORMATTYPE1,FORMATTYPE2,...) returns the eps
%   associated with the quantizers associated with FORMATTYPE1, ....
%
%   [ECOEFFICIENT, EINPUT, EMULTIPLICAND, EOUTPUT, EPRODUCT, ESUM] = EPS(F) returns
%   the eps associated with the coefficient, input, multiplicand, output, product
%   and sum quantizers, respectively.
%
%   If the MATLAB workspace display format is HEX, then the eps are
%   displayed in hexadecimal format.
%
%   If the MATLAB workspace display format is RAT, then the eps are
%   displayed in rational format.
%
%   Example:
%     Hq = qfilt;
%     format hex
%     eps(Hq)
%
%     format rat
%     eps(Hq)
%
%     format
%     eps(Hq)
%
%   See also QFILT, QUANTIZER, QUANTIZER/EPS.

%   Thomas A. Bryan, 29 September 1999
%   Copyright 1999-2002 The MathWorks, Inc.
%   $Revision: 1.10 $  $Date: 2002/04/14 15:29:22 $


[varargout{1:nargout}] = qformat(Hq,'eps',varargin{:});
