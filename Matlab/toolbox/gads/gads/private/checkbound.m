function [lb,ub,msg,exitflag] = checkbound(lbin,ubin,nvars,verbosity)
%CHECKBOUND Move the initial point within the (valid) bounds.
%   [X,LB,UB,X,FLAG] = CHECKBOUNDS(X0,LB,UB,nvars) checks that the upper and lower
%   bounds are valid (LB <= UB) and the same length as X (pad with -inf/inf
%   if necessary); warn if too long.  Also make LB and UB vectors if not 
%   already. Finally, inf in LB or -inf in UB throws an error.

%   Copyright 2004 The MathWorks, Inc.
%   $Revision: 1.9.6.1 $  $Date: 2004/02/01 21:44:16 $
%   Mary Ann Branch 

msg = [];
exitflag = 1;

% Turn into column vectors
lb = lbin(:); 
ub = ubin(:); 
lenlb = length(lb);
lenub = length(ub);

% Check maximum length
if lenlb > nvars
       warning('gads:CHECKBOUND:lengthOfLowerBound','Length of lower bounds is > length(x); ignoring extra bounds.');
       lb = lb(1:nvars);   
    lenlb = nvars;
elseif lenlb < nvars
    lb = [lb; -inf*ones(nvars-lenlb,1)];
    lenlb = nvars;
end

if lenub > nvars
       warning('gads:CHECKBOUND:lengthOfUpperBound','Length of upper bounds is > length(x); ignoring extra bounds.');
       ub = ub(1:nvars);
    lenub = nvars;
elseif lenub < nvars
    ub = [ub; inf*ones(nvars-lenub,1)];
    lenub = nvars;
end

% Check feasibility of bounds
len = min(lenlb,lenub);
if any( lb( (1:len)' ) > ub( (1:len)' ) )
   count = full(sum(lb>ub));
   if count == 1
      msg=sprintf(['Exiting due to infeasibility:  %i lower bound exceeds the' ...
            ' corresponding upper bound.'],count);
   else
      msg=sprintf(['Exiting due to infeasibility:  %i lower bounds exceed the' ...
            ' corresponding upper bounds.'],count);
   end 
   exitflag = -2;
end
% check if -inf in ub or inf in lb   
if any(eq(ub, -inf)) 
   error('gads:CHECKBOUND:infUpperBound','-Inf detected in upper bound: upper bounds must be > -Inf.');
elseif any(eq(lb,inf))
   error('gads:CHECKBOUND:infLowerBound','+Inf detected in lower bound: lower bounds must be < Inf.');
end
