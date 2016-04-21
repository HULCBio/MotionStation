function display(this)
% Display method for @SignalConstraint class.

%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/11 00:45:49 $
nc = numel(this);
if nc==1
   s = get(this);
   disp(' ')
   disp(rmfield(get(this),'SignalSource'))
   disp('Signal Constraint.')
else
   disp(sprintf('%d-by-1 vector of Signal Constraints.',nc))
end