function [g,dceq] = dcgain(sys)
%DCGAIN  DC gain of LTI models.
%
%   K = DCGAIN(SYS) computes the steady-state (D.C. or low frequency)
%   gain of the LTI model SYS.
%
%   If SYS is an array of LTI models with dimensions [NY NU S1 ... Sp],
%   DCGAIN returns an array K with the same dimensions such that
%      K(:,:,j1,...,jp) = DCGAIN(SYS(:,:,j1,...,jp)) .  
%
%   See also NORM, EVALFR, FREQRESP, LTIMODELS.

%   Author(s): A. Potvin, 12-1-95
%   Revised: P. Gahinet, 4-1-96
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.24 $  $Date: 2002/04/10 06:13:02 $

[z,p,k,Ts] = zpkdata(sys);
sizes = size(k);
g = zeros(sizes);
dceq = struct('factor',zeros(sizes),'power',zeros(sizes));
RealFlag = isreal(sys);

if Ts==0,
   s = 0;  % Evaluate at s=0 for continuous-time models
else
   s = 1;  % Evaluate at z=1 for discrete-time models
end

for i=find(k(:))',
   % Only consider k(i)~=0 (g=0 and dceq=0 when k=0)
   zi = z{i};
   pi = p{i};   
   f = k(i);  % factor f in f * s^m equivalent
   
   % Find multiplicity of num and den roots at s=0 or z=1
   if Ts
       % Discrete-time: denoise multiple roots near 1
       TolOne = sqrt(eps); % Detection of roots at z=1
       indz = find(abs(zi-1)<0.01);
       indp = find(abs(pi-1)<0.01);
       z1m = mroots(zi(indz),'roots');
       p1m = mroots(pi(indp),'roots');
       % Replace multiple roots by average value if there are roots at z=1
       if any(abs(z1m-1)<TolOne)
           zi(indz,1) = z1m;   
       end
       if any(abs(p1m-1)<TolOne)
           pi(indp,1) = p1m;
       end
       % Locate roots at z=1
       indz = find(abs(zi-1)<TolOne);
       indp = find(abs(pi-1)<TolOne);
   else
       % Continuous-time: look for hard zeros (anything else is adhoc and can give 
       % meaningless answer for VLF systems)
       indz = find(zi==0);
       indp = find(pi==0);
   end
   zi(indz,:) = [];
   pi(indp,:) = [];
   
   % G(i) ~ f * s^m as s->0
   m = length(indz) - length(indp);
   if f~=0
      f = pow2(log2(f) + sum(log2(s-zi)) - sum(log2(s-pi)));
      if RealFlag
         f = real(f);
      end
   end
   if m<0,
      g(i) = Inf;
   elseif m>0,
      g(i) = 0;
   else
      g(i) = f;
   end
   dceq.factor(i) = f;
   dceq.power(i) = m;
end

if RealFlag,
   g = real(g);  
end

