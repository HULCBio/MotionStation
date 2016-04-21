function s = bfitcreateeqnstrings(fit,pp,resid)
% BFITCREATEEQNSTRINGS Create result strings Basic Fitting GUI.

%   Copyright 1984-2002 The MathWorks, Inc.
%   $Revision: 1.11 $  $Date: 2002/04/15 04:06:23 $

switch fit
case {0,1}
    s = sprintf('%s\n\nNorm of residuals = \n     0',eqnstring(fit));
otherwise
    s = sprintf('%s',eqnstring(fit));

    s = sprintf('%s\n\nCoefficients:\n',s);
    for i=1:length(pp)
    	s=[s sprintf('  p%g = %0.5g\n',i,pp(i))];
    end
    
    s = sprintf('%s\n%s\n',s,'Norm of residuals = ');
    s = [s '     ' num2str(resid,5) sprintf('\n')];

end

%-------------------------------

function s = eqnstring(fitnum)

if isequal(fitnum,0)
    s = 'Spline interpolant';
elseif isequal(fitnum,1)
    s = 'Shape-preserving interpolant';
else
    fit = fitnum - 1;
    s = sprintf('y =');
    for i = 1:fit
        s = sprintf('%s p%s*x^%s +',s,num2str(i),num2str(fit+1-i));
        if isequal(mod(i,2),0)
            s = sprintf('%s\n     ',s);
        end
    end
    s = sprintf('%s p%s ',s,num2str(fit+1));
end

    