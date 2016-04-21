function display(this)
% Display method for @ParamSet class.

%   Author(s): P. Gahinet
%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/11 00:45:40 $
GridSize = [this.Grid_.Length];
if isempty(GridSize)
   Ns = 0;
else
   Ns = prod(GridSize);
end
s = rmfield(get(this),'MetaData');
disp(s)
if length(GridSize)<=1
   disp(sprintf('Scattered set with %d parameter vectors.',Ns))
else
   str = sprintf('%dx',GridSize);
   disp(sprintf('%s grid of parameter vectors.',str(1:end-1)))
end