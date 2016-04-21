function graderr(finite_diff_deriv, analytic_deriv, evalstr2)
%GRADERR Used by SIMCNSTR

%   Copyright 1990-2002 The MathWorks, Inc.
%   $Revision: 1.17 $

err=max(max(abs(analytic_deriv-finite_diff_deriv)));
disp(sprintf('Maximum discrepancy between derivatives  = %g',err));
if (err > 1e-6*norm(analytic_deriv) + 1e-5) 
  disp('Warning: Derivatives do not match within tolernace')
  disp('Derivative from finite difference calculation:')
  finite_diff_deriv
  disp(['User-supplied derivative, ', evalstr2, ' : '])
  analytic_deriv
  disp('Difference:')
  analytic_deriv - finite_diff_deriv
  disp('Strike any key to continue or Ctrl-C to abort')
  pause 
end
