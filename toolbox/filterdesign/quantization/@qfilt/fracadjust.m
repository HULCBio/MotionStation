function Hn = fracadjust(Hq)
%   Copyright 1999-2002 The MathWorks, Inc.
%   $Revision: 1.2 $  $Date: 2002/04/03 22:15:32 $

wrn = warning('off');
Hn = copyobj(Hq);

q = Hn.coefficientformat;
switch mode(q)
  case {'fixed','ufixed'}
   % Only adjust coefficient fraction length for fixed-point.
   maxcoeff = maxabscoeff(Hn);
   % The fractionlength should be adjusted so that the max abs coefficient fits.

   % Subtract tol because roundoff in the factorization may cause
   % ceil to overdo the scaling if the maximum coefficient is close to
   % an exact power of 2.
   if maxcoeff >=1 & maxcoeff > eps(q)
     maxcoeff = maxcoeff - eps(q);
   end
   headroom = ceil(log2( maxcoeff ));
   w = q.wordlength;
   f = w-headroom-1;
   q.fractionlength = f;
   set(Hn,'coefficientformat',q);
end

warning(wrn)

function x = maxabscoeff(Hq)
x = -inf;
rcoeff = referencecoefficients(Hq);
if isnumeric(rcoeff{1})
  rcoeff = {rcoeff};
end
for j=1:length(rcoeff)
  for k=1:length(rcoeff{j})
    x = max(x,max(abs(rcoeff{j}{k})));
  end
end
  