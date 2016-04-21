%function [freq,mag] = terpol(freqin,magin,npts)
%
%   This function interpolates the irregularly spaced
%   frequency/magnitude data FREQIN and MAGIN,
%   in the following way.  First, it assumes that
%   FREQIN is a row vector of nonnegative frequencies,
%   between 0 and pi:
%   foreach 1 <= i <= NPTS
%      if      pi*(i-1)/NPTS  <  FREQIN(1),
%        then    FREQ(i)  :=  MAG(1)
%      if      FREQIN(length(FREQIN))  <=  pi*(i-1)/NPTS
%        then    MAGOUT((i) =  MAGIN(length(MAGIN))
%      for other values of FREQIN(i), the program does
%      linear interpolation between data points

%   Copyright 1991-2004 MUSYN Inc. and The MathWorks, Inc.
% $Revision: 1.7.2.3 $

function [freq,mag] = terpol(freqin,magin,npts)

lmagin = (1/log(10))*log(magin);
freq = (pi/npts)*(0:npts-1);
lmag = zeros(1,npts);
topval = length(freqin);
p = find(freq<freqin(1));
lmag(p) = lmagin(1)*ones(1,length(p));
p = find(freqin(topval)<=freq);
lmag(p) = lmagin(topval)*ones(1,length(p));
for i=2:topval
    %p=find(freq>=freqin(i-1) & freq<freqin(i));
    p = ceil(npts*freqin(i-1)/pi+1):(ceil(npts*freqin(i)/pi+1)-1);
    rat = freq(p) - freqin(i-1)*ones(1,length(p));
    rat = (1/(freqin(i)-freqin(i-1)))*rat;
    lmag(p)=(ones(1,length(p))-rat)*lmagin(i-1)+rat*lmagin(i);
end
mag = exp(log(10)*lmag);