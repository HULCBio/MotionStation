function PO = overshoot(Constr)
%OVERSHOOT  Computes overshoot level for given damping

%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.3 $  $Date: 2002/04/10 05:10:38 $

% RE: based on second-order behavior
z = Constr.Damping;
if z==1
    PO = 0;
else
    % PO = 100 * exp(-pi*z/sqrt(1-z^2))
    PO = 100*exp(-pi*z/sqrt(1-z)/sqrt(1+z));
end
