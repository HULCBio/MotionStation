function [des,wt] = taperedresp(order, ff, grid, wtx, aa, varargin)
%TAPEREDRESP Example for a user-supplied frequency-response function.

%   Author(s): D. Shpak
%   Copyright 1999-2002 The MathWorks, Inc.
%   $Revision: 1.10 $  $Date: 2002/04/14 15:16:36 $



nbands = length(ff)/2;
% Create output vectors of the appropriate size
des=grid;
wt=grid;

for i=1:nbands
   k = find(grid >= ff(2*i-1) & grid <= ff(2*i));
   npoints = length(k);
   des(k) = linspace(aa(2*i-1), aa(2*i), npoints);
   if i == 1 
      wt(k) = wtx(i) * (1.5 + cos((0:npoints-1)*pi/(npoints-1)));
   elseif i == nbands
      wt(k) = wtx(i) * (1.5 + cos(pi+(0:npoints-1)*pi/(npoints-1)));
   else
      wt(k) = wtx(i) * (1.5 - cos((0:npoints-1)*2*pi/(npoints-1)));
   end
end
