%   fresp = cepstr(w,mag)
%
%   Uses the complex-cepstrum (Oppenheim & Schafer, Digital
%   Signal Processing, p. 501) to generate, at the frequencies
%   W, a complex frequency response FRESP whose magnitude is
%   equal to magnitude data MAG and whose phase corresponds
%   to a stable, minimum phase transfer function.
%
%   See also  MRFIT, MAGSHAPE.

%   Authors: Andy Packard and Gary Balas
%   Copyright 1995-2004 The MathWorks, Inc.
%       $Revision: 1.6.2.3 $

function fresp = cepstr(w,mag)

if nargin ~= 2
   error('usage: fresp = cepstr(w,mag)');
end

w=w'; mag=mag';
[w,ind]=sort(w); mag=mag(ind);
dnum=length(w);

pw = sqrt(w(dnum)*w(1));
capt = 1/pw;
tcomes = capt*capt*(w.^2);

% warp the frequencies around the disk
% dw has values between 0 and pi

dw = acos((1-tcomes)./(1+tcomes));
lowf=dw(1);
highf = dw(length(dw));
if lowf <= 0 | highf >= pi
  error('The frequencies W should be positive')
end

smgap = min([lowf pi-highf]);
nn = ceil( (log(2*pi/smgap))/log(2) );
npts = 2*(2^nn);
hnpts = 2^nn;
if npts < 4096
  npts = 4096;
  hnpts = 2048;
end


% interpolate the frequency and magnitude data to
%    hnpts points linearly spaced around top half of disk

lmagin = (1/log(10))*log(mag);
lindw = (pi/hnpts)*(0:hnpts-1);
lmag = zeros(1,hnpts);
topval = length(dw);
p = find(lindw<dw(1));
lmag(p) = lmagin(1)*ones(1,length(p));
p = find(dw(topval)<=lindw);
lmag(p) = lmagin(topval)*ones(1,length(p));
for i=2:topval
  p=find(lindw>=dw(i-1) & lindw<dw(i));
  rat = lindw(p) - dw(i-1)*ones(1,length(p));
  rat = (1/(dw(i)-dw(i-1)))*rat;
  lmag(p)=(ones(1,length(p))-rat)*lmagin(i-1)+rat*lmagin(i);
end
linmag = exp(log(10)*lmag);


% duplicate data around disk

dome = [lindw,(2*pi)-fliplr(lindw)];         %all disk
mag = [linmag,fliplr(linmag)];               %all disk

% complex cepstrum to get min-phase

ymag = log( mag .^2 );
ycc = ifft(ymag);                              % 2^N
nptso2 = npts/2;                               % 2^(N-1)
xcc = ycc(1:nptso2);                           % 2^(N-1)
xcc(1) = xcc(1)/2;                             % halve it at 0
xhat = exp(fft(xcc));                          % 2^(N-1)
domeg = dome(1:2:nptso2-1);                    % 2^(N-2)
xhat = xhat(1:nptso2/2);                       % 2^(N-2)


% interpolate back to original frequency data

nptsslo = length(dw);
nptsfst = length(domeg);
if domeg(1)<=dw(1) & domeg(nptsfst)>=dw(nptsslo)
  fresp = zeros(1,nptsslo);
  for i=1:nptsslo
    p = min(find(domeg>=dw(i)));
    rat = (dw(i)-domeg(p-1))/(domeg(p)-domeg(p-1));
    fresp(i) = rat*xhat(p) + (1-rat)*xhat(p-1);
  end
else
  error('not sampled high enough')
end

fresp=fresp(:);
