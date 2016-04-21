function plotpoly(varargin)
%PLOTPOLY  Plot polygon.
%   PLOTPOLY(X,Y,S) plots polygon.
%
%   PLOTPOLY(MAT,S) uses the column vectors in MAT.

%  Written by:  A. Kim
%  Copyright 1996-2003 The MathWorks, Inc.
%  $Revision: 1.3.4.1 $    $Date: 2003/08/01 18:19:36 $



if nargin==3
	xcell = varargin{1};
	ycell = varargin{2};
	s = varargin{3};
elseif nargin==2
	mat = varargin{1};
	s = varargin{2};
	xcell = mat(:,1);
	ycell = mat(:,2);
else
	error('Incorrect number of arguments')
end

% set up plot
% figure; hold on; axis equal; grid on
% set(gca,'xlim',[0 12],'ylim',[0 10])
% xl = [floor(min(x))-1, ceil(max(x))+1];
% yl = [floor(min(y))-1, ceil(max(y))+1];
% xl(1) = floor(min([get(gca,'xlim'), xl]));
% xl(2) = ceil(max([get(gca,'xlim'), xl]));
% yl(1) = floor(min([get(gca,'ylim'), yl]));
% yl(2) = ceil(max([get(gca,'ylim'), yl]));
% set(gca,'xlim',xl,'ylim',yl,'xtick',xl(1):xl(2),'ytick',yl(1):yl(2))

if ~iscell(xcell)
	xcell = {xcell};
	ycell = {ycell};
end

for n=1:length(xcell)

% cell element
x = xcell{n};
y = ycell{n};

% account for polygons with inner holes
% if isempty(find(isnan(x)))
	x = [x; nan];
	y = [y; nan];
% end
nanindx = find(isnan(x));

% draw outer contour and show starting point
indx = 1:nanindx(1)-1;
plot(x(indx),y(indx),s,'linewidth',2);
plot(x(1),y(1),[s(1) 'o'],'markersize',14)

% draw contour direction arrow
%arrow([x(1) y(1)],[x(2) y(2)],'edgecolor',s(1),'facecolor',s(1),...
%		'length',16,'baseangle',45);

% draw inner holes and show starting points and direction arrows
for n=1:length(nanindx)-1
	indx = nanindx(n)+1:nanindx(n+1)-1;
	plot(x(indx),y(indx),s);
	plot(x(indx(1)),y(indx(1)),[s(1) 'o'],'markersize',12)
%	arrow([x(indx(1)) y(indx(1))],[x(indx(2)) y(indx(2))],...
%			'edgecolor',s(1),'facecolor',s(1),...
%			'length',10,'baseangle',45);
end

end  % cell element
