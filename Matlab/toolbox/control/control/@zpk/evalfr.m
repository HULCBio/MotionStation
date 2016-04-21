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
%   $Revision: 1.15.4.1 $  $Date: 2002/11/11 22:22:16 $

error(nargchk(2,2,nargin))
if length(s)~=1,
   error('Use FREQRESP for vectors of frequencies.')
end
sizes = size(sys.k);

% Get delays
Td = totaldelay(sys);
isdelayed = any(Td(:));
if isdelayed
   Td = repmat(Td,[1 1 sizes(1+ndims(Td):end)]);
else
   Td = 0;
end

% Evaluate response at S
fresp = zeros(sizes);

if isinf(s)
	% Case s=Inf
	for m=1:prod(sizes),
		fresp(m) = LocalRespInf(sys.z{m},sys.p{m},sys.k(m),Td(min(m,end)));
	end
	
else
	% Evaluate rational part of the response
   for m=1:prod(sizes),
      zs = s - sys.z{m};
      ps = s - sys.p{m};
      if any(ps==0)
         fresp(m) = Inf;
      elseif ~any(zs==0)
         % RE: Beware of overflow in prod(zs) or prod(ps)
         fresp(m) = sys.k(m) * pow2(sum(log2(zs)) - sum(log2(ps)));
		end
	end
	
	% Add delay contribution
	if isdelayed,
		if isct(sys),
			fresp = exp(-s*Td) .* fresp;
		else
			fresp = s.^(-Td) .* fresp;
		end
	end
   
   % Enforce realness
   if isreal(s) & isreal(sys)
      fresp = real(fresp);
   end
   
end

%------------------- Local functions ------------------


function resp = LocalRespInf(z,p,k,Td)

if ~k | length(z)<length(p)
   resp = 0;
elseif length(z)>length(p)
   resp = Inf;
elseif Td
   resp = NaN;
else
   resp = k;
end
