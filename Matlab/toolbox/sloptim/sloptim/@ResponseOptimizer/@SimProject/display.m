function display(this)
% Display method for @SimProject class.

%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/11 00:46:09 $
np = numel(this);
if np==1
   disp(' ')
   disp(rmfield(get(this),'OptimStatus'))
   disp('Simulink Response Optimization Project.')
else
   disp(sprintf('%d-by-1 vector of SRO projects.',np))
end