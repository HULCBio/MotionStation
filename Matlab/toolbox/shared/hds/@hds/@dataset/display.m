function display(this)
%DISPLAY  Display method for @dataset class.

%   Author(s): P. Gahinet
%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2004/04/11 00:29:20 $
GridSize = [this.Grid_.Length];
if isempty(GridSize)
   Ns = 0;
else
   Ns = prod(GridSize);
end
disp(get(this))
if length(GridSize)<=1
   disp(sprintf('Hierarchical data set with %d data points',Ns))
else
   str = sprintf('%dx',GridSize);
   disp(sprintf('Hierarchical data set with %s grid of data points',str(1:end-1)))
end