function [p1,p2] = polyinit(x1,y1,x2,y2)
%POLYINIT  Polygon initialization.
%   [P1,P2] = POLYINIT(X1,Y1,X2,Y2) performs an initial inspection of
%   polygons to determine if the polygons are completely inside or outside
%   of one another, in order to simplify the polygon boolean operations.

%  Written by:  A. Kim
%  Copyright 1996-2003 The MathWorks, Inc.
%  $Revision: 1.3.4.1 $ $Date: 2003/08/01 18:19:37 $

err = eps*1e4;

% determine if polygons are similar
if length(x1)==length(x2) & all(ismember([x1 y1],[x2 y2],'rows'))
	p1 = 'in';
	p2 = 'in';
	return
end

% calculate intersection points
[xi,yi,ii] = polyxpoly(x1,y1,x2,y2,'unique');

% initialize outputs
p1 = 'na';  p2 = 'na';

% determine if polygon 1 is completely inside or outside of polygon 2
% can include no more than 1 vertex border
pin = inpolygonerr(x1(2:end),y1(2:end),x2,y2,err);
indxi = find(pin==1);
indxo = find(pin==0);
indxb = find(pin==.5);
ni = length(indxi);
no = length(indxo);
nb = length(indxb);
np = length(pin);
p1 = [];
if ni==np | (nb==1 & ni==np-1)
	p1 = 'in';
elseif no==np | (nb==1 & no==np-1)
	if length(xi)<=1
		p1 = 'out';
	else
		p1 = 'na';
	end
end

% determine if polygon 2 is completely inside or outside of polygon 1
% can include no more than 1 vertex border
pin = inpolygonerr(x2(2:end),y2(2:end),x1,y1,err);
indxi = find(pin==1);
indxo = find(pin==0);
indxb = find(pin==.5);
ni = length(indxi);
no = length(indxo);
nb = length(indxb);
np = length(pin);
p2 = [];
if ni==np | (nb==1 & ni==np-1)
	p2 = 'in';
elseif no==np | (nb==1 & no==np-1)
	if length(xi)<=1
		p2 = 'out';
	else
		p2 = 'na';
	end
end
