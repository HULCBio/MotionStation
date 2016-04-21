function [lb,ub,errstr,wstr,errid,warnid] = checkbounds(lbin,ubin,nvars)
%CHECKBOUNDS checks bounds validity.
%   [LB,UB,ERRSTR,WSTR,ERRID,WARNID] = CHECKBOUNDS(LB,UB,nvars) 
%   checks that the upper and lower bounds are valid (LB <= UB) and the same 
%   length as X (pad with -inf/inf if necessary); warn if too long.  Also make 
%   LB and UB vectors if not already.
%   Finally, inf in LB or -inf in UB throws an error.

%   Copyright 2001-2004 The MathWorks, Inc.
%   $Revision: 1.4.2.2 $  $Date: 2004/02/01 21:43:24 $

errstr = '';
errid = '';
wstr = '';
warnid = '';
% Turn into column vectors
lb = lbin(:); 
ub = ubin(:); 

lenlb = length(lb);
lenub = length(ub);

tooManyLowerBounds = false;
tooManyUpperBounds = false;
% Check maximum length
if lenlb > nvars
   warnid = 'curvefit:checkbounds:tooManyLowerBounds';
   wstr = ('Length of lower bounds is > number of coefficients; ignoring extra bounds.');
   lb = lb(1:nvars);   
   lenlb = nvars;
   tooManyLowerBounds = true;
elseif lenlb < nvars
   lb = [lb; -inf*ones(nvars-lenlb,1)];
   lenlb = nvars;
end

if lenub > nvars
   warnid = 'curvefit:checkbounds:tooManyUpperBounds';
   wstr = ('Length of upper bounds is > number of coefficients; ignoring extra bounds.');
   ub = ub(1:nvars);
   lenub = nvars;
   tooManyUpperBounds = true;
elseif lenub < nvars
   ub = [ub; inf*ones(nvars-lenub,1)];
   lenub = nvars;
end

if tooManyLowerBounds && tooManyUpperBounds
   warnid = 'curvefit:checkbounds:tooManyBounds';
   wstr = ('Length of upper and lower bounds is > number of coefficients; ignoring extra bounds.');
end

% Check feasibility of bounds
len = min(lenlb,lenub);
if any( lb( (1:len)' ) > ub( (1:len)' ) )
   count = full(sum(lb>ub));
   if count == 1
      errid = 'curvefit:checkbounds:lowerBoundExceedsUpperBound';
      errstr = sprintf(['\nExiting due to infeasibility:  %i lower bound exceeds the' ...
            ' corresponding upper bound.\n'],count);
      return;
   else
      errid = 'curvefit:checkbounds:lowerBoundsExceedsUpperBounds';
      errstr = sprintf(['\nExiting due to infeasibility:  %i lower bounds exceed the' ...
            ' corresponding upper bounds.\n'],count);
      return;
   end 
end
% check if -inf in ub or inf in lb   
if any(eq(ub, -inf)) 
   errid = 'curvefit:checkbounds:invalidUpperBound';
   errstr = ('-Inf detected in upper bound: upper bounds must be > -Inf.');
   return;
elseif any(eq(lb,inf))
   errid = 'curvefit:checkbounds:invalidLowerBound';
   errstr = ('+Inf detected in lower bound: lower bounds must be < Inf.');
   return;
end

