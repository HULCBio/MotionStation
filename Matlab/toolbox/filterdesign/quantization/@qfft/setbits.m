function varargout = setbits(F,fmt)
%SETBITS  Set all data format property values for quantized FFTs.
%   SETBITS(F, FMT) sets all data format property values for quantized
%   FFT F.
%
%   If F is a fixed-point quantized FFT, then FMT = [w, f] where w is
%   the wordlength and f is the fractionlength.  The coefficient, input,
%   output, and multiplicand formats are set to [w, f].  The product and
%   sum formats are set to [2w,2f].
%
%   If F is a floating-point quantized FFT, then FMT = [w, e] where w is
%   the wordlength and e is the exponentlength.  All formats are set to
%   [w, e].
%
%   If the specified formats are greater than the maximum allowed, then
%   they are set to the maximum.
%
%   Example:
%     F = qfft;
%     F = setbits(F,[8 7])
%   Sets the coefficient, input, output, and multiplicand formats to
%   [8 7], and the product and sum formats to [16 14].
%
%   See also QFFT, QFFT/SET.

%   Thomas A. Bryan, 24 June 1999
%   Copyright 1999-2002 The MathWorks, Inc.
%   $Revision: 1.15 $  $Date: 2002/04/14 15:26:10 $

mode = F.coefficientformat.mode;
try
  switch mode
    case 'float'
      fmt(1) = min(fmt(1),64);
      fmt(2) = min(fmt(2),11);
      F.coefficientformat = setformat(F.coefficientformat,'format',fmt);
      F.inputformat = setformat(F.inputformat,'format',fmt);
      F.outputformat = setformat(F.outputformat,'format',fmt);
      F.multiplicandformat = setformat(F.multiplicandformat,'format',fmt);
      F.productformat = setformat(F.productformat,'format',fmt);
      F.sumformat = setformat(F.sumformat,'format',fmt);
    case 'fixed'
      fmt = limitfixedfmt(fmt);
      fmt2 = limitfixedfmt(2*fmt);
      F.coefficientformat = setformat(F.coefficientformat,'format',fmt);
      F.inputformat = setformat(F.inputformat,'format',fmt);
      F.outputformat = setformat(F.outputformat,'format',fmt);
      F.multiplicandformat = setformat(F.multiplicandformat,'format',fmt);
      F.productformat = setformat(F.productformat,'format',fmt2);
      F.sumformat = setformat(F.sumformat,'format',fmt2);
  end
catch
  error(lasterr)
end

if nargout==0
  % setbits(F,[8 7])
  assignin('caller',inputname(1),F)
else
  % F1 = setbits(F,[8 7])
  % [F1,F2,...] = setbits(F,[8 7])
  for k=1:nargout
    varargout{k} = F;
  end
end

function q = setformat(q,property,value)
set(q,property,value)

function fmt = limitfixedfmt(fmt)
if length(fmt)<2
  error('Format must be a vector of length 2.');
end
fmt(1) = min(fmt(1),53);
fmt(2) = min(fmt(2),fmt(1)-1);

