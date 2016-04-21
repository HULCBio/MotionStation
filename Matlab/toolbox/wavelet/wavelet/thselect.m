function thr = thselect(x,tptr)
%THSELECT Threshold selection for de-noising.
%   THR = THSELECT(X,TPTR) returns threshold X-adapted value 
%   using selection rule defined by string TPTR.
%   
%   Available selection rules are:
%   TPTR = 'rigrsure', adaptive threshold selection using 
%       principle of Stein's Unbiased Risk Estimate.
%   TPTR = 'heursure', heuristic variant of the first option.
%   TPTR = 'sqtwolog', threshold is sqrt(2*log(length(X))).
%   TPTR = 'minimaxi', minimax thresholding.
%
%   Threshold selection rules are based on the underlying 
%   model y = f(t) + e where e is a white noise N(0,1).
%   Dealing with unscaled or nonwhite noise can be handled
%   using rescaling output threshold THR (see SCAL parameter
%   in WDEN).
%
%   See also WDEN.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 12-Mar-96.
%   Last Revision: 14-May-2003.
%   Copyright 1995-2004 The MathWorks, Inc.
% $Revision: 1.10.4.2 $

x = x(:)';
n = length(x);
switch tptr
    case 'rigrsure'
        sx2 = sort(abs(x)).^2;
        risks = (n-(2*(1:n))+(cumsum(sx2)+(n-1:-1:0).*sx2))/n;
        [risk,best] = min(risks);
        thr = sqrt(sx2(best));

    case 'heursure'
        hthr = sqrt(2*log(n));
        eta = (norm(x).^2-n)/n;
        crit = (log(n)/log(2))^(1.5)/sqrt(n);
        if eta < crit
            thr = hthr;
        else
            thr = min(thselect(x,'rigrsure'),hthr);
        end

    case 'sqtwolog'
        thr = sqrt(2*log(n));

    case 'minimaxi'
        if n <= 32
            thr = 0;
        else
            thr = 0.3936 + 0.1829*(log(n)/log(2));
        end

    otherwise
        error('Invalid argument value')
end
