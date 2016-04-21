% function yout = vfft(yin,n)
%
%  Perform an N length FFT on the VARYING matrix YIN.  N is optional,
%  defaulting to the number of INDEPENDENT VARIABLEs in YIN.  If N is
%  greater than the number of INDEPENDENT VARIABLEs in YIN, the data
%  is zero padded.  If N is less the data is truncated.  The MATLAB
%  function FFT is used for the actual calculation.
%
%  It is assumed that the YIN is a time scale in seconds and YOUT is
%  returned with a frequency scale in radians/sec.  The time scale
%  is assumed to be monotonic and only the first interval is used
%  to determine the frequency scale.
%
%   See also:  FFT, IFFT and  VIFFT.

%   Copyright 1991-2004 MUSYN Inc. and The MathWorks, Inc.
% $Revision: 1.7.2.3 $

function Y = vfft(y,n)

if nargin == 0,
    disp('usage: Y = vfft(y,n)')
    return
    end

[type,nr,nc,npts] = minfo(y);
if type == 'syst',
    error('input is not VARYING or CONSTANT')
    return
    end

if type == 'cons',
    Y = y;
    return
    end

if nargin == 1,
    length = npts;
elseif nargin == 2,
    length = n;
else
    error('too many arguments')
    return
    end

[ydat,yptr,t] = vunpck(y);
tinc = t(2) - t(1);

finc = 2*pi/(tinc*length);
omega = [0:finc:finc*(length-1)];


Y = [];
for i = 1:nr,
    Yrow = [];
    for j = 1:nc
      if (nr == 1) & (nc == 1)
        [ydata,yptr,t] = vunpck(y);
      else
        [ydata,yptr,t] = vunpck(sel(y,i,j));
      end
        sisoY = fft(ydata,length);
        sisoY = vpck(sisoY,omega);
        Yrow = sbs(Yrow,sisoY);
        end
    Y = abv(Y,Yrow);
    end