function parallelui(action)

%PARALLELUI Tool for interactively modifying map parallels
%  
%    PARALLELUI provides a tool to modify the standard parallels of a displayed 
%    map projection.  One or two red lines are displayed where the standard 
%    parallels are currently located.  The parallel lines can be dragged to new 
%    locations.  Double-clicking on one of the standard parallels reprojects the 
%    map using the new parallel locations.
%   
%    PARALLELUI ON activates parallel tool.  PARALLELUI OFF de-activates the 
%    tool.  PARALLELUI will toggle between these two states.
%  
%    See also AXESM, SETM


%  Copyright 1996-2003 The MathWorks, Inc.
% $Revision: 1.4.4.1 $
%  Written by:  W. Stumpf, E. Byrns, E. Brown

if nargin == 0;
	action = 'toggle';
end

switch action
case 'on'

	if ~ismap; error('Map axes required'); end
	
	% check for already on
	hpar = findobj(gca,'Tag','paralleluiline');
	if ~isempty(hpar); return; end

	% retrieve map structure
	mstruct = getm(gca);
	
	% retrieve parallels
	parlat = mstruct.mapparallels;
	nparallels = mstruct.nparallels;
	
	if nparallels == 0;	return; end

	% reset origin so parallels are displayed relative to the 
	% base projection, not the potentially skewed final projection
	mstruct.origin = [0 0 0];
	
	% put the parallels at the max z so they are visually above everything (including grid)

	zmax = max(zlim);
	
	% add parallel lines to map
	for i=1:nparallels
		
		lon = angledim(0:2:360,'degrees',mstruct.angleunits);
		lat = ones(size(lon))*parlat(i);

		[x,y,z,savepts] = mfwdtran(mstruct,lat,lon,[],'line');
		
		savepts.parallel = parlat(i);

		hline = plot3(x,y,zmax*ones(size(x)), 'ButtonDownFcn','parallelui(''down'')',...
							'EraseMode','xor','Tag','paralleluiline',...
							'Color','r','LineWidth',2,'UserData',savepts);
	
	end
						
	restack(hline,'top') % ensure top of stacking order so we can grab it
	
case 'toggle'         %  Toggle origin marker visible and invisible
       hline = findobj(gca,'Tag','paralleluiline');
	   if isempty(hline)           %  Initial call.  No marker exists
            if ~ismap;  error('Not a valid map axes');  end
	        parallelui('on')
	   elseif strcmp(get(hline,'Visible'),'on')    %  Turn off
	        parallelui('off')
	   elseif strcmp(get(hline,'Visible'),'off')    %  Turn on
	        parallelui('on')
	   end
   
case 'down'

	switch get(gcf,'SelectionType')
		      case 'alt',    parallelui('off')
			  case 'extend', parallelui('startmove')
			  case 'open',   parallelui('apply')
			  case 'normal', parallelui('startmove')
     end

case 'startmove'
	 	
	% set windowbuttonmotion and windowbuttonup functions
	set(gcf,'WindowButtonMotionFcn','parallelui(''linemove'')');
	set(gcf,'WindowButtonUpFcn','parallelui(''lineup'')');
	set(gcbo,'Linewidth',4)

case 'linemove'

	% get current point and update its location
	cpoint = get(gca,'CurrentPoint');
	
	% retrieve map structure and reset origin to base projection
	mstruct = getm(gca);
	mstruct.origin = [0 0 0];

	% convert to lat,lon
	[latd,lond] = minvtran(mstruct,cpoint(1,1),cpoint(1,2),1);
	
	epsilon = epsm(mstruct.angleunits);
	latd = min( ...
			max( latd , min(mstruct.flatlimit)+epsilon ), ...
								max(mstruct.flatlimit)-epsilon );
	
	lond = min( ...
			max( lond , min(mstruct.flonlimit)+epsilon ), ...
								max(mstruct.flonlimit)-epsilon );
	
	lon = angledim(0:2:360,'degrees',mstruct.angleunits);
	lat = ones(size(lon))*latd;

	[x,y,z,savepts] = mfwdtran(mstruct,lat,lon,[],'line');

	zmax = max(zlim);
	
	% update parallel line
	savepts.parallel = latd;
	set(gco,'xdata',x,'ydata',y,'zdata',zmax*ones(size(x)),'UserData',savepts)

	
	
case 'lineup'

	set(handlem('paralleluiline'),'Linewidth',2)

% clear windowmotion and buttonup functions
	set(gcf,'WindowButtonMotionFcn','');
	set(gcf,'WindowButtonUpFcn','');

	refresh % to clear up artifacts from dragging in xor mode
	
case 'apply'

	pointer = get(gcf,'pointer');
	set(gcf,'pointer','watch')
	% Clear windowmotion and buttonup functions
	set(gcf,'WindowButtonMotionFcn','');
	set(gcf,'WindowButtonUpFcn','');

	% Retrieve parallels
	
	hpar = findobj(gca,'Tag','paralleluiline');
	parallels = [];
	for i=1:length(hpar)
		mstruct = getm(hpar(i));
		parallels = [parallels mstruct.parallel];
% 		delete(hpar(i))
	end
	
	% Reset map parallels. SETM will turn parallels off, 
	% reproject the data, and then turn parallels on.

	setm(gca,'mapparallels',parallels);

	set(gcf,'pointer',pointer)	
	
case 'off'

	% clear windowmotion and buttonup functions
	set(gcf,'WindowButtonMotionFcn','');
	set(gcf,'WindowButtonUpFcn','');

	% retreive parallels
	
	hpar = findobj(gca,'Tag','paralleluiline');
	delete(hpar)
	refresh
	
	% restore buttondown functions

end

