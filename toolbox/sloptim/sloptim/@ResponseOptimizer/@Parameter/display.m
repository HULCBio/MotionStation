function display(this)
% Display method for @Parameter class.

%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/11 00:45:45 $
np = numel(this);
if np==1
   disp(' ')
   disp(get(this))
   disp('Tuned parameter.')
else
   disp(sprintf('%d-by-1 vector of Tuned Parameters.',np))
end