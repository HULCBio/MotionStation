function [ff,aa,free_edges] = firpmedge(ff, aa, edge_prop)
%
% Check for unconstrained band-edge frequencies or fixed gain points.
% Used by FIRPM2.
%
%  [ff,aa,free_edges] = firpmedge(ff, aa, edge_prop)
%          ff: vector of band edges
%          aa: desired values at band edges
%   edge_prop: cell array of character strings:
%              'n': normal edge
%              'f': exactly-specified point (error=0 at this point)
%              's': single-point band
%              'i': indeterminate band edge.  Used when bands abut.
%
%         ff: vector of band edges.  Possibly modified by an 's'
%         aa: desired values at band edges.  Possibly modified by 's'
% free_edges: one value per band edge:
%              1: indeterminate band edge.
%              0: normal band edge.
%             -1: exactly-specified point.

%   Author(s): D. Shpak
%   Copyright 1999-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/12 23:25:43 $

free_edges = zeros(1, length(ff));
if isempty(edge_prop)
   return;
end
if length(ff) ~= length(edge_prop)
   error('Number of edges and edge properties must be equal');
end
if ~ischar(strcat(edge_prop{:}))
   error('Each edge properties must be a character');
end

offset = 0;
nEdges = length(edge_prop);
for i=1:nEdges
   prop = lower(edge_prop{i});
   switch prop
   case 'f'
      % Edge is exactly fixed
      free_edges(i+offset) = -1;
   case 'i'
      % Edge is at a "nominal" indeterminate frequency and can move
      if (i == 1 | i == nEdges)
         error 'The first and last band-edge frequencies must be specified exactly';
      end
      free_edges(i+offset) = 1;
   case 's'
      if rem((i+offset),2) == 0
          error ('A ''s''ingle-point band must occur between bands, not inside of a band');
      end
      % Duplicate the edge for single-point bands
      free_edges(i+offset) = -1;
      free_edges(i+offset+1) = -1;
      ff = [ff(1:i+offset) ff(i+offset:end)];
      aa = [aa(1:i+offset) aa(i+offset:end)];
      offset = offset + 1;
   case 'n'
      free_edges(i+offset) = 0;
   otherwise
      error ('Unknown edge property character');
   end
end

%
% Unconstrained band edges on both sides of the transition
% region are not allowed since you can't set up a grid
% for that case
%
nbands = length(ff)/2;
for i = 1:nbands-1
if (free_edges(2*i) == 1 & free_edges(2*i+1) == 1)
	error (['Unconstrained band-edge frequencies on both sides of a ' ...
				'transition region are not allowed']);
   end
end
   
