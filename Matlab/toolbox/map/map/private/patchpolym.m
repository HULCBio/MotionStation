function hcell = patchpolym(varargin)
%PATCHPOLY  Patch polygon.
%   PATCHPOLYM(X,Y,C) plots polygon.
%
%   PATCHPOLYM(MAT,C) uses the column vectors in MAT.

%  Written by:  A. Kim
%  Copyright 1996-2003 The MathWorks, Inc.
%  $Revision: 1.3.4.1 $    $Date: 2003/08/01 18:19:35 $



if nargin==3
	xcell = varargin{1};
	ycell = varargin{2};
	c = varargin{3};
elseif nargin==2
	mat = varargin{1};
	c = varargin{2};
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

if length(c)<length(xcell)
	c = repmat(c,[1 ceil(length(xcell)/length(c))]);
end

for nc=1:length(xcell)

count = 1;
	
% cell element
x = xcell{nc};
y = ycell{nc};

% account for polygons with inner holes
% if isempty(find(isnan(x))) | ~isnan(x(end))
	x = [x; nan];
	y = [y; nan];
% end
nanindx = find(isnan(x));

% draw outer contour
indx = 1:nanindx(1)-1;
h(count,1) = patchm(x(indx),y(indx),c(nc));

% draw inner holes
for n=1:length(nanindx)-1
	count = count + 1;
	indx = nanindx(n)+1:nanindx(n+1)-1;
	h(count,1) = patchm(x(indx),y(indx),'k','zdata',.1*ones(size(indx)));
end

hcell{nc,1} = h;
clear h;

end  % cell element
