function graderr(finite_diff_deriv, analytic_deriv, gradfcn)
%GRADERR Used to check gradient discrepancy in optimization routines. 

%   Copyright 2001-2004 The MathWorks, Inc. 
%   $Revision: 1.3.2.1 $  $Date: 2004/02/01 21:43:29 $

try
    gradfcnstr = char(gradfcn);
catch
    gradfcnstr = '';
end

finite_diff_deriv = full(finite_diff_deriv); 
analytic_deriv = full(analytic_deriv);
err=max(max(abs(analytic_deriv-finite_diff_deriv)));
disp(sprintf('Maximum discrepancy between derivatives  = %g',err));
if (err > 1e-6*norm(analytic_deriv) + 1e-5) 
    disp('Warning: Derivatives do not match within tolerance')
    disp('Derivative from finite difference calculation:')
    finite_diff_deriv
    if ~isempty(gradfcnstr)
        disp(['User-supplied derivative, ', gradfcnstr ': '])
    else 
        disp(['User-supplied derivative: '])
    end
    analytic_deriv
    disp('Difference:')
    analytic_deriv - finite_diff_deriv
    disp('Strike any key to continue or Ctrl-C to abort')
    pause 
end
