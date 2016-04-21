function varargout = num2bin(Hq)
%NUM2BIN  Number to binary string.
%   NUM2BIN(Hq) with no left-hand-side argument displays the quantized
%   coefficients in QFILT object Hq as binary strings.
%
%   C = NUM2BIN(Hq) with a left-hand-side argument returns a cell array
%   of quantized coefficients as binary strings.  Cell array C is
%   configured the same as cell array Hq.QuantizedCoefficients.
%
%   If the coefficient format is float, double, or single, then the
%   coefficients are converted to IEEE-style binary strings.
%
%   If the coefficient format is fixed, then the coefficients are
%   converted to two's complement binary strings.
%
%   Example:
%     Hq = qfilt;
%     num2bin(Hq)
%
%   See also QFILT, QFILT/NUM2HEX, QUANTIZER/NUM2HEX, QUANTIZER/NUM2BIN.

%   Thomas A. Bryan 22 June 1999
%   Copyright 1999-2002 The MathWorks, Inc.
%   $Revision: 1.13 $  $Date: 2002/04/14 15:29:16 $

error(nargchk(0,1,nargin))

q = quantizer(Hq,'coefficient');

% Disable warnings until the end.
warnmode = warning;
warning off
oldnover = get(q,'noverflows');

% Do the conversion.
coeffs = get(Hq,'QuantizedCoefficients');
C = num2bin(q,coeffs);

% Restore warn mode and warn if new overflows occurred and warning is on
warning(warnmode);
warning(overflowmsg(q,oldnover));

if nargout==1
  % Return the cell array of strings.
  varargout{1} = C;
else
  % Display.
  name = inputname(1);
  if isempty(name)
    name = 'ans';
  end
  celldisp(C,[name,'.QuantizedCoefficients']);
end
