function y = update(hconstLine)
% UPDATE  Update constantlineseries based on axes limits.

%   Copyright 1984-2004 The MathWorks, Inc. 
%   $Revision: 1.1.4.1 $  $Date: 2004/03/30 13:07:15 $

hAxes = ancestor(hconstLine,'axes');
if isequal(hconstLine.DependVar,'y') % y = f(x)
    lim = get(hAxes, 'xlim');
else % x = f(y);
    lim = get(hAxes, 'ylim');
end

val = hconstLine.Value;
lenv = length(val);
if isequal(lenv,1)
    if isequal(hconstLine.DependVar,'y')
        set(hconstLine, 'xdata', lim, 'ydata', [val val]);
    else
        set(hconstLine, 'xdata', [val val], 'ydata', lim);
    end
else % More than one value to plot lines.
    val = (val(:))';
    x = zeros(2*lenv + lenv - 1);
    x = repmat([lim NaN],1,lenv);
    y = x; 
    y = reshape([ repmat(val,2,1); repmat(NaN,1,lenv)], 1, length(x));
    if isequal(hconstLine.DependVar,'y')
        set(hconstLine, 'xdata', x, 'ydata', y);
    else
        set(hconstLine, 'xdata', y, 'ydata', x);
        
    end
end
% Opaque array methods to know how many left-hand-sides were
% requested, so we must always return one argument.
y = [];


