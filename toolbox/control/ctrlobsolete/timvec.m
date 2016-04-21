function t=timvec(a,b,c,x0,st,precision)
%TIMVEC Returns a time vector for use with time response functions.
%   T=TIMVEC(a,b,c,X0,ST,PRECISION) returns a time vector T
%   for use with state space systems (a,b,c) that have known 
%   initial conditions X0. The time vector can be used,
%   for instance, for step and impulse responses. 
%   
%   TIMVEC attempts to produce a vector that ensures the 
%   output responses have decayed to approx. ST % of their initial 
%   or peak values. 
%
%   More points are used for rapidly changing systems. 
%   Nominal point resolution is determined by setting PRECISION
%   (a good value is 30 points). For more resolution set PRECISION
%   to, for example, 50. 

%   A.C.W.Grace 9-21-89
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.9 $  $Date: 2002/04/10 06:32:14 $

if nargin<6, 
   precision = 30; 
end
if nargin<5, 
   st = 0.005; 
end
if nargin<4, 
x0 = ones(length(a),1); 
end
[r,n]=size(c);

% Work out scale factors by looking at d.c. gain, 
% eigenvectors and eigenvalues of the system.
[m,r]=eig(a);
r=diag(r);

% Equate the  responses to the sum of a set of 
% exponentials(r) multiplied by a vector of magnitude terms(vec).
[r1,n]=size(c);
if r1>1, 
   c1=max(abs(c)); 
else
   c1=c; 
end

% Cater for the case when m is singular
if rcond(m)<eps 
   vec = (c1*m).'.*(1e4*ones(n,1)); 
else 
   vec=(c1*m).'.*(m\x0);
end

% Cater for the case when poles and zeros cancel each other out:
vec=vec+1e-20*(vec==0);

% Cater for the case when eigenvectors are singular:
% d.c. gain (not including d matrix)
dcgain=c1*x0; % or dcgain =real(sum(vec)) or dcgain=-c(iu,:)/a*b  

% If the d.c gain is small then base the scaling
% factor on the estimated maximum peak in the response.
if abs(dcgain)<1e-8,
   % Estimation of the maximum peak in the response.
   estt=(atan2(imag(vec),real(vec))./(imag(r)+eps*(imag(r)==0)))';
   % Next line caters for unstable systems .
   estt=(estt<1e12).*estt+(estt>1e12)+(estt==0);
   peak=vec.'*exp(r*abs(estt));
   pk=max([abs(dcgain);abs(peak');eps]);
else
   pk=dcgain;
end
if ~finite(pk),
   pk = 1/eps; 
end

% Work out the st% settling time for the responses.
% (or st% peak value settling time for low d.c. gain systems).
lt=(st*pk./(abs(vec).*(1+(imag(r)~=0))));

% The addition of (r==0) and 0.01*(real(r)==0) below, 
% fixes problem for pure integrators and purely imaginary systems.
t1=real(log(lt))./(real(r)+(r==0)+0.1*imag(r).*(real(r)==0));
ts=max(t1);

% Next line is just in case numerical problems are encountered
if ts<=0, ts=max(abs(t1))+eps; end

% Round the maximum time to an appropriate value for plotting.
tsn=chop(ts,1,5);
if abs((ts-tsn)/ts)>0.2, 
   tsn=chop(ts,1,1);
   if abs((ts-tsn)/ts)>0.2
      tsn=chop(ts,2,2);
   end
end
ts=tsn;

% Calculate the  number of points to take for the response.
% The first part of this calculation is based on the speed 
% and magnitude of the real eigenvalues.
% The second part is concerned with the oscillatory part of the
% response (imaginary eigenvalues).
% The factors in the imaginary calculation are the damping ratio, the
% residues, the frequency and the final time.         
r=r+(real(r)==0); % Purely imaginary roots and integrators
vec = vec + eps*(real(vec)==0); % Can occur with purely imaginary zeros 
npts=round(max(abs(precision/5*real(vec)./max(abs(real(vec)))*ts.*real(r)) ...
   + precision/2*(log(1+abs(vec./(pk).*( imag(r)./real(r) ).* imag(r)/pi))*ts)));
if npts>precision*30, npts=precision*30; end
t=0:ts/npts:ts;      

% end timvec
