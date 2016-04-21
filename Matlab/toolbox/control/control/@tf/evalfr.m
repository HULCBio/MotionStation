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
%	 Copyright 1986-2002 The MathWorks, Inc. 
%	 $Revision: 1.12 $  $Date: 2002/04/10 06:08:04 $

error(nargchk(2,2,nargin))
if length(s)~=1,
   error('Use FREQRESP for vectors of frequencies.')
end
sizes = size(sys.num);

% Get delays
Td = totaldelay(sys);
isdelayed = any(Td(:));
if isdelayed
   Td = repmat(Td,[1 1 sizes(1+ndims(Td):end)]);
else
   Td = 0;
end

% Evaluate response
fresp = zeros(sizes);

if isinf(s)
   % Case s=Inf
   for k=1:prod(sizes),
      fresp(k) = LocalRespInf(sys.num{k},sys.den{k},Td(min(k,end)));
   end
   
else
   % Evaluate rational part
   for k=1:prod(sizes),
      fresp(k) = polyval(sys.num{k},s)/polyval(sys.den{k},s);
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


%------------------- Local functions ------------------


function resp = LocalRespInf(num,den,Td)

if ~any(num)
   resp = 0;
else
   idx = find(num);   num = num(idx(1):end);
   idx = find(den);   den = den(idx(1):end);
   if length(num)<length(den)
      resp = 0;
   elseif length(num)>length(den)
      resp = Inf;
   elseif Td
      resp = NaN;
   else
      resp = num(1)/den(1);
   end
end
