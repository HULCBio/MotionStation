function columnErr = jacColumnErr(finite_diff_deriv,analytic_deriv,jac_column_number)
% JACCOLUMNERR Used to check discrepancy between a column of the user-supplied
% Jacobian and a finite difference estimation of that same column.
%
%   Copyright 1990-2004 The MathWorks, Inc.
%   $Revision: 1.1.4.1 $  $Date: 2004/02/07 19:13:39 $

finite_diff_deriv = full(finite_diff_deriv); 
analytic_deriv = full(analytic_deriv);

% We store the difference because we may need it to 
% to compute discrepantIndices
difference = analytic_deriv-finite_diff_deriv;

columnErr = max(abs(difference));
if (columnErr > 1e-6*norm(analytic_deriv) + 1e-5)
   discrepantIndices = abs(difference) > 1e-6*norm(analytic_deriv) + 1e-5;
   discrepantElements = (find(discrepantIndices))';
   disp(sprintf(['Warning - Derivatives do not match within tolerance ' ...
                 'in Jacobian column %i:\n'], jac_column_number))
   disp(sprintf('Element       User-supplied Jacobian  Finite-difference Jacobian  Difference'))
   for k = discrepantElements 
      disp(sprintf('(%5.0f,%5.0f)   %12.3g      %12.3g            %12.3g',...
                   k,jac_column_number,analytic_deriv(k),finite_diff_deriv(k), ...
                   difference(k)))
   end
   disp('Strike any key to continue or Ctrl-C to abort')
   pause 
end
