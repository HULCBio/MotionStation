% function out = sisorat(freq,gain)
%    or
% function out = sisorat(data_g)
%
%   Finds a first order, stable transfer function that has a
%   gain of GAIN at a frequency FREQ. In the case of one
%   input argument, DATA_G must be a 1x1 VARYING matrix, with
%   1 data point. The INDEPENDENT VARIABLE is interpreted as
%   FREQ, and the value of the matrix is interpreted as GAIN.
%   The transfer function produced has constant magnitude
%   across frequencies.
%
%   See also: DYPERT, MU, RANDEL, UNWRAPP.

%   Copyright 1991-2004 MUSYN Inc. and The MathWorks, Inc.
% $Revision: 1.7.2.3 $

function out = sisorat(freq,gain)
 if nargin < 1
   disp('usage: out = sisorat(freq,gain)')
   return
 end

 if nargin == 1
   [ftype,frows,fcols,fnum] = minfo(freq);
   sss = freq;
   if ftype == 'vary'
     if frows == 1 & fcols == 1 & fnum == 1
       freq = sss(1,2);
       gain = sss(1,1);
     else
       error('if input is varying, it should be 1pt, 1x1')
       return
     end
   else
     error('if only 1 input, it should be 1pt, 1x1')
     return
   end
 end
 if isempty(freq) | isempty(gain)
   error('need non-empty frequency and gain')
   out = [];
   return
 end
 if freq < 0
   error('need non-negative frequency')
   out = [];
   return
 end
 if freq == 0 & imag(gain) ~= 0
   error('need nonzero frequency for complex gain')
   return
 end
 if abs(gain) < 1e-13
  disp('WARNING_IN_SISORAT: gain is zero')
  out = 0.0;
  return
 end
 disk = gain/abs(gain);
 if abs(imag(disk)) < abs(real(disk))*(1e-8)
	disk = real(disk);
	%	gain = abs(gain);
	gain = real(gain);
 end
 sw = 1;

 if imag(disk) == 0
   out = gain;
 else
   if imag(disk) < 0
     sw = -1;
     disk = -disk;
   end
   pscal = sqrt(abs(gain));
   beta = (imag(disk)*freq)/(1+real(disk));
   bc = sqrt(2*beta);
   out = [-beta -pscal*bc 1 ; pscal*sw*bc pscal*pscal*sw 0 ; 0 0 -inf];
 end
%
%