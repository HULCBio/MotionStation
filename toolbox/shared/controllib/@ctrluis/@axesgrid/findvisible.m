function [ax,indrow,indcol] = findvisible(h)
%FINDVISIBLE  Finds visible rows and columns in axes grid.
           
%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/11 00:16:46 $

axgrid = h.Axes2d;
vis = reshape(strcmp(get(axgrid,'Visible'),'on'),size(axgrid));
indrow = find(any(vis,2));
indcol = find(any(vis,1))';
ax = axgrid(indrow,indcol);