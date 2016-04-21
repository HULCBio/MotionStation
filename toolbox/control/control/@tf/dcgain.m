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

%   Author(s): A. Potvin, P. Gahinet
%	 Copyright 1986-2002 The MathWorks, Inc. 
%	 $Revision: 1.15 $  $Date: 2002/04/10 06:08:10 $

% RE: DCEQ.mfactor(i,j)=f and DCEQ.power(i,j)=m  if  Hij(s) ~ f * s^m as s->0
%     Used in BODERESP to determine true phase at s=0

tol = sqrt(eps);
[num,den,Ts] = tfdata(sys);
sizes = size(num);
g = zeros(sizes);
dceq = struct('factor',zeros(sizes),'power',zeros(sizes));

for i=1:prod(sizes),
   n = num{i};
   d = den{i};
   if any(n),
      % Find number of roots at s=0 or z=1 in num and den
      if Ts==0,
         in = find(n);
         zn = length(n) - in(end);
         id = find(d);
         zd = length(d) - id(end);
         % G(i) ~ f * s^m  as s-> 0
         m = zn - zd;
         f = n(in(end))/d(id(end));
      else
         zn = 0;
         while all(abs(sum(n))<tol*max(abs(n)))
            zn = zn + 1;
            % remove root at z=1
            n = fliplr(filter(-1,[1 -1],fliplr(n(2:end))));
         end
         zd = 0;
         while all(abs(sum(d))<tol*max(abs(d))),
            zd = zd + 1;
            d = fliplr(filter(-1,[1 -1],fliplr(d(2:end))));
         end
         % G(i) ~ f * (z-1)^m  as z->1
         m = zn - zd;
         f = sum(n)/sum(d);
      end
      
      % Set value of G(i) and dceq(i)
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
end  % end for

