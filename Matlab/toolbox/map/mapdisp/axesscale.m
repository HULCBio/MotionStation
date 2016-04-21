function axesscale(baseaxes,ax)
%  AXESSCALE Resize axes for equivalent scale. 
% 
%  AXESSCALE resizes all axes in the current figure to have the same scale 
%  as the current axes (gca). In this context, scale means the relationship 
%  between axes X and Y coordinates to figure and paper coordinates. The 
%  XLimMode and YLimMode of the axes are set to Manual to prevent autoscaling 
%  from changing the scale
% 
%  AXESSCALE(hbase) uses the axes hbase as the reference axes, and rescales  
%  the other axes in the current figure.
% 
%  AXESSCALE(hbase,hother) uses the axes hbase as the base axes, and rescales  
%  only the axes hother.
% 
%  See also PAPERSCALE

%  Written by: W. Stumpf, L. Job
%  Copyright 1996-2003 The MathWorks, Inc.
%  $Revision: 1.6.4.1 $  $Date: 2003/08/01 18:17:47 $


checknargin(0,2,nargin,mfilename);
if nargin == 0
	baseaxes = gca;
	ax = findobj(gcf,'type','axes');
elseif nargin == 1
	ax = findobj(gcf,'type','axes');
end

% check that the base handle is to an axes
if length(baseaxes(:)) > 1
   eid = sprintf('%s:%s:invalidBaseAxesLength', getcomp, mfilename);
   error(eid,'%s','Only one base axes at a time'); 
end

if any(~ishandle([baseaxes;ax(:)])) 
   eid = sprintf('%s:%s:invalidHandle', getcomp, mfilename);
   error(eid,'%s','Inputs must be axis handles');
end

type = get(baseaxes,'type');
if ~strcmp(type,'axes')
   eid = sprintf('%s:%s:invalidBaseAxesType', getcomp, mfilename);
   error(eid,'%s','Inputs must be axis handles');
end

ellipsoid = []; 
if ismap(baseaxes)
	ellipsoid = getm(baseaxes,'geoid');
end

% check that the other handles are to axes

warned = 0;
for i=1:length(ax)
	type = get(ax(i),'type');
	if ~strcmp(type,'axes')
       eid = sprintf('%s:%s:invalidHandle', getcomp, mfilename);
       error(eid,'%s','Inputs must be axis handles');
   end

% Check that ellipsoids are approximately the same to ensure that scaling 
% between geographic and x-y data is the same

	if ismap(ax(i))
		thisellipsoid = getm(baseaxes,'geoid');
	else
		thisellipsoid = [];
	end
	
	if ~isempty(ellipsoid) &  ~isempty(thisellipsoid) &  abs((ellipsoid(1)-thisellipsoid(1))/ellipsoid(1))  > 0.01 ; 
		if ~warned
         wid = sprintf('%s:%s:ellipsoidUnitsDiffer', getcomp, mfilename);
			warning(wid,'%s','ellipsoids differ between axes. Check that units of ellipsoids are the same')
			warned = 1;
		end
	end
end

% get the properties of BASEAXES

xlim = get(baseaxes,'xlim');
ylim = get(baseaxes,'ylim');
pos = get(baseaxes,'pos');
deltax = pos(3);
deltay = pos(4);

% set the xscale and yscale

xscale = deltax/abs(diff(xlim));
yscale = deltay/abs(diff(ylim));

% loop on remaining axes

for i = 1:size(ax,1)
	type = get(ax(i),'type');
	switch type
		case 'axes'
			xlim = abs(diff(get(ax(i),'xlim')));
			ylim = abs(diff(get(ax(i),'ylim')));
			pos = get(ax(i),'pos');
			pos(3) = xscale*xlim;
			pos(4) = yscale*ylim;
			set(ax(i),'pos',pos);
	end
end

% Lock down xlim and ylim to ensure that scale remains constant if
% additional data is plotted

set([baseaxes;ax(:)],'xLimMode','manual','ylimmode','manual');
