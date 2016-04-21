function varargout = num2hex(Hq)
%NUM2HEX  Number to hex string.
%   NUM2HEX(Hq) with no left-hand-side argument displays the quantized
%   coefficients in QFILT object Hq as hex strings.
%
%   C = NUM2HEX(Hq) with a left-hand-side argument returns a cell array
%   of quantized coefficients as hex strings.  Cell array C is
%   configured the same as cell array Hq.QuantizedCoefficients.
%
%   If the coefficient format is float, double, or single, then the
%   coefficients are converted to IEEE-style hex strings.
%
%   If the coefficient format is fixed, then the coefficients are
%   converted to two's complement hex strings.
%
%   Example:
%     Hq = qfilt;
%     num2hex(Hq)
%
%   See also QFILT, QFILT/NUM2BIN, QUANTIZER/NUM2HEX, QUANTIZER/NUM2BIN.

%   Thomas A. Bryan 22 June 1999
%   Copyright 1999-2002 The MathWorks, Inc.
%   $Revision: 1.13 $  $Date: 2002/04/14 15:29:13 $

error(nargchk(0,1,nargin))

q = quantizer(Hq,'coefficient');


% Disable warnings until the end.
warnmode = warning;
warning off
oldnover = get(q,'noverflows');

% Do the conversion.
coeffs = get(Hq,'QuantizedCoefficients');
C = num2hex(q,coeffs);

% Restore warn mode and warn if new overflows occurred and warning is on.
warning(warnmode)
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
