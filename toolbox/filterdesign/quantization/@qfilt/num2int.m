function varargout = num2int(Hq)
%NUM2INT  Number to signed integer.
%   NUM2INT(Hq) with no left-hand-side argument displays the quantized
%   coefficients in QFILT object Hq as signed integers.
%
%   C = NUM2INT(Hq) with a left-hand-side argument returns a cell array
%   of quantized coefficients as signed integers.  Cell array C has the
%   same dimensions as Hq.QuantizedCoefficients.
%
%   Example:
%     Hq = qfilt;
%     num2int(Hq)
%
%   See also QFILT, QFILT/NUM2BIN, QFILT/NUM2HEX, 
%   QUANTIZER/NUM2BIN, QUANTIZER/NUM2HEX, QUANTIZER/NUM2INT.

%   Thomas A. Bryan 7 July 2000
%   Copyright 1999-2002 The MathWorks, Inc.
%   $Revision: 1.3 $  $Date: 2002/04/14 15:31:24 $

error(nargchk(0,1,nargin))

q = quantizer(Hq,'coefficient');

switch lower(mode(q))
  case {'float','double','single'}
    warning(['NUM2INT is only meaningful for fixed-point.  ',...
          'Returning floating-point values.'])
end

% Disable warnings until the end.
warnmode = warning;
warning off
oldnover = get(q,'noverflows');

% Do the conversion.
coeffs = get(Hq,'QuantizedCoefficients');
C = num2int(q,coeffs);

% Restore warn mode and warn if new overflows occurred and warning is on.
warning(warnmode)
warning(overflowmsg(q,oldnover));

if nargout==1
  % Return the cell array.
  varargout{1} = C;
else
  % Display.
  name = inputname(1);
  if isempty(name)
    name = 'ans';
  end
  fmt = get(0,'format');
  set(0,'format','long g');
  celldisp(C,[name,'.QuantizedCoefficients']);
  set(0,'format',fmt);
end
