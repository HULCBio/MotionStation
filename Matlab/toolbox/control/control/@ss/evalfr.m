function fresp = evalfr(sys,s)
%EVALFR  Evaluate frequency response at a single (complex) frequency.
%
%   FRESP = EVALFR(SYS,X) evaluates the transfer function of the 
%   continuous- or discrete-time LTI model SYS at the complex 
%   number S=X or Z=X.  For state-space models, the result is
%                                   -1
%       FRESP =  D + C * (X * E - A)  * B   .
%
%   EVALFR is a simplified version of FREQRESP meant for quick 
%   evaluation of the response at a single point.  Use FREQRESP 
%   to compute the frequency response over a grid of frequencies.
%
%   See also FREQRESP, BODE, SIGMA, LTIMODELS.

%   Author(s):  P. Gahinet  5-13-96
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.14 $  $Date: 2002/04/10 06:01:52 $

error(nargchk(2,2,nargin))
if length(s)~=1,
   error('Use FREQRESP for the vector case.')
end
sizes = size(sys.d);

% Get delays
Td = totaldelay(sys);
isdelayed = any(Td(:));
if isdelayed
   Td = repmat(Td,[1 1 sizes(1+ndims(Td):end)]);
else
   Td = 0;
end

% Evaluate response at S
if isinf(s)
   % Case s=Inf
   fresp = sys.d;
   fresp(fresp~=0 & Td~=0) = NaN;
   
else
   % Evaluate rational part of the response
   fresp = zeros(sizes);
   for k=1:prod(sizes(3:end)),
      e = sys.e{k};
      if isempty(e),
         e = eye(size(sys.a{k}));
      end
      fresp(:,:,k) = sys.d(:,:,k) + sys.c{k} * ((s*e-sys.a{k})\sys.b{k});
   end
   
   % Add delay contribution
   if isdelayed,
      if isct(sys),
         fresp = exp(-s*Td) .* fresp;
      else
         fresp = s.^(-Td) .* fresp;
      end
   end
end

