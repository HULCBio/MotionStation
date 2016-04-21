% function yout = vifft(yin)
%
%  Perform an inverse FFT on the VARYING matrix Y.  It is assumed
%  that the YIN is a frequency scale in rad/sec and YOUT is returned
%  with a time scale in seconds.  The frequency scale is assumed to
%  be monotonic and only the first interval is used to determine
%  the time scale.
%
%  See also:  FFT, IFFT and  VIFFT.

%   Copyright 1991-2004 MUSYN Inc. and The MathWorks, Inc.
% $Revision: 1.7.2.3 $

%  30apr92      GJB     modified the code such that if there is only one
%                       input and output of the varying matrix, the SEL
%                       command is NOT called. Speeds code up for this case
%                       by a factor of 2.5.

function y = vifft(Y)
if nargin ~= 1,
	disp('usage: y = vifft(Y)')
	return
	end

[type,nr,nc,npts] = minfo(Y);
if type == 'syst',
    error('input is not VARYING or CONSTANT')
    return
    end

if type == 'cons' | npts == 1,
    y = Y;
    return
    end

[Ydat,yptr,w] = vunpck(Y);
winc = w(2) - w(1);
tinc = 2*pi/(winc*npts);
t = [0:tinc:tinc*(npts-1)];

y = [];
for i = 1:nr,
    yrow = [];
    for j = 1:nc
      if (nr == 1) & (nc == 1)
        [Ydat,yptr,w] = vunpck(Y);
      else
        [Ydat,yptr,w] = vunpck(sel(Y,i,j));
      end
        sisoy = ifft(Ydat);
        sisoy = vpck(sisoy,t);
        yrow = sbs(yrow,sisoy);
        end
    y = abv(y,yrow);
    end
%
%