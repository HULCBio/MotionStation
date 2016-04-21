function Th = getSimTime(this)
% Computes simulation horizon and time points needed for proper 
% constraint evaluation.

%   $Revision: 1.1.6.4 $ $Date: 2004/04/11 00:45:55 $
%   Copyright 1986-2004 The MathWorks, Inc.
Th = zeros(0,1);
if hasConstraint(this)
   % Hits all constraint vertices exactly (constraint value is highly sensitive to
   % solver sampling when response "cuts corners")
   % RE: vertices are discontinuity points in constraint function
   Th = [Th ; this.LowerBoundX(:) ; this.UpperBoundX(:)];
end
