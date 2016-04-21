function varargout = setbits(Hq,fmt)
%SETBITS  Set all data format property values for quantized filters.
%   SETBITS(Hq, FMT) sets all data format property values for quantized
%   filter Hq.
%
%   If Hq is a fixed-point quantized filter, then FMT = [w, f] where w
%   is the wordlength and f is the fractionlength.  The coefficient,
%   input, output, and multiplicand formats are set to [w, f].  The
%   product and sum formats are set to [2w,2f].
%
%   If Hq is a floating-point quantized filter, then FMT = [w, e] where
%   w is the wordlength and e is the exponentlength.  All formats are
%   set to [w, e].
%
%   Example:
%     Hq = qfilt;
%     Hq = setbits(Hq,[8 7])
%   Sets the coefficient, input, and output, and multiplicand formats
%   to [8 7], and the product and sum formats to [16 14].
%
%   See also QFILT, QFILT/SET.

%   Thomas A. Bryan, 24 June 1999
%   Copyright 1999-2002 The MathWorks, Inc.
%   $Revision: 1.19 $  $Date: 2002/04/14 15:32:02 $

mode = Hq.coefficientformat.mode;
try
  switch mode
    case 'float'
      fmt(2) = min(fmt(2),32);  % Exponent is in a long int, 32 bits
      Hq = set(Hq,'format',fmt);
    case 'fixed'
      fmt = limitfixedfmt(fmt);
      fmt2 = 2*fmt;
      Hq = set(Hq,'coefficientformat',fmt,...
          'inputformat',fmt,...
          'outputformat',fmt,...
          'multiplicandformat',fmt,...
          'productformat',fmt2,...
          'sumformat',fmt2);
  end
catch
  error(lasterr)
end

if nargout==0
  % setbits(Hq,[8 7])
  assignin('caller',inputname(1),Hq)
else
  % F1 = setbits(Hq,[8 7])
  % [F1,F2,...] = setbits(Hq,[8 7])
  for k=1:nargout
    varargout{k} = Hq;
  end
end

function fmt = limitfixedfmt(fmt)
if length(fmt)<2
  error('Format must be a vector of length 2.');
end
% Limit the fractionlength (or exponentlength) to be less than the
% wordlength. 
fmt(2) = max(min(fmt(2),fmt(1)-1),0);

