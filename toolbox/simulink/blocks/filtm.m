function [at,bt,ct,dt,freq,mag] = filtm(filt,trans,cutoff,bw,npts,P1,P2,P3)
%FILTM  Analog filter design for masked blocks in Simulink system MASKFILT.
%   This M-file is used to return the state-space matrices and frequency 
%   response for given filter design routines and frequency ranges.
%
%   [A,B,C,D,FREQ,MAG] = FILTM('FILT','TRANS',CUTOFF,BW,NPTS,P1,P2,P3) 
%   returns the state-space matrices, A, B, C, D, and the magnitude response 
%   FREQ, MAG for a given filter design function 'FILT' (e.g. 'BUTTAP') and 
%   filter transformation 'TRANS' (e.g. 'LP2BP').
%
%   CUTOFF and BW are the cutoff frequency and bandwidth of the filter in
%   radians/sec.
%
%   NPTS defines the number of points for the frequency response.
%   P1, P2, P3 are the parameters for the filter design.
%
%   See also MASKFILT, BUTTAP, LP2BP

%   Copyright 1990-2002 The MathWorks, Inc.
%   $Revision: 1.22 $
%   Andrew Grace 5-30-91.

% Get LP analog prototype
a=-1;b=1;c=1;d=1;freq=1:10; mag=1:10;
if nargin == 8
  [z,p,k] = feval(filt,P1,P2,P3);
elseif nargin == 7
  [z,p,k] = feval(filt,P1,P2);
else
  [z,p,k] = feval(filt,P1);
end

% Conversion e.g. lp2bp
if length(z)
  k = real(prod(-p)/prod(-z)); 
else 
  k = real(prod(-p));
end
[a,b,c,d]=zp2ss(z,p,k); 
if length(bw)
  %[at,bt,ct,dt] = feval(trans,a,b,c,d,cutoff,bw)); (Buggy)
  [at,bt,ct,dt] = eval([trans,'(a,b,c,d,cutoff,bw)']);
else
  %[at,bt,ct,dt] = feval([trans,a,b,c,d,cutoff,bw)); (Buggy)
  [at,bt,ct,dt] = eval([trans,'(a,b,c,d,cutoff)']);
end
% Frequency response
[num,den]=ss2tf(at,bt,ct,dt,1); 
w=logspace(log10(cutoff/10),log10(10*cutoff),npts); 
h=freqs(num,den,w); 
freq = 20*log10(w);
mag = 20*log10(abs(h));
