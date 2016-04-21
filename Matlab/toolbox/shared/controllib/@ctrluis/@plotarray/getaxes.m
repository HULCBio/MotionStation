function ax = getaxes(h)
%GETAXES  Returns ND array of HG axes for rectangular plot arrays.
% 
%   The output is an array of size [M1 N1 M2 N2 ....] for a rectangular
%   plot array with nested grids of size [M1 N1], [M2 N2],...

%   Author(s): P. Gahinet
%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:18:19 $

if isa(h.Axes(1),'hg.axes')
   % Leaf node
   ax = h.Axes;
else
   % Get HG axes for each cell in plot array (recursive building)
   s = size(h.Axes);
   ax = cell(s);
   for ct=1:prod(s),
      subax = getaxes(h.Axes(ct));
      ax{ct} = reshape(subax,[1 size(subax)]);
   end
   % Generate array of axes
   ax = cat(1,ax{:});
   sax = size(ax);
   ax = reshape(ax,[s sax(2:end)]);
end
