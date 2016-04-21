function [hout,htout] = mdistort(action,levels,gsize)

% MDISTORT displays contours of constant distortion on a map
% 
%   MDISTORT, with no input arguments, toggles the display of contours of 
%   projection-induced distortion on the current map axes.  The magnitude of 
%   the distortion is reported in percent.
%   
%   MDISTORT OFF removes the contours.
%   
%   MDISTORT('PARAMETER') or MDISTORT PARAMETER displays contours of 
%   distortion for the specified parameter.  Recognized parameter strings are 
%   'area', 'angles' for the maximum angular distortion of right angles, 
%   'scale' or 'maxscale' for the maximum scale, 'minscale' for the minimum 
%   scale, 'parscale' for scale along the parallels, 'merscale' for scale 
%   along the meridians, and 'scaleratio' for the ratio of maximum and 
%   minimum scale.  If omitted, the 'maxscale' parameter is displayed.  All 
%   parameters are displayed as percent distortion, except angles, which are
%   displayed in degrees.
% 
%   MDISTORT(parameter,levels) specifies the levels for which the contours 
%   are drawn.  levels is a vector of values as used by CONTOUR. If omitted, 
%   the default levels are used.
%   
%   MDISTORT('parameter',levels, gsize) controls the size of the underlying  
%   graticule matrix used to compute the contours.  gsize is a two-element  
%   vector containing the number of rows and columns.  If omitted, the default 
%   Mapping Toolbox graticule size of [50 100] is assumed.
% 
%   [h,ht] = MDISTORT(...) returns the handles to the line and text objects.
%
%   Note:  MDISTORT may not be valid when used with UTM, and distortion is
%          minimal within a given UTM zone. MDISTORT issues a warning if a
%          UTM projection is encountered.
%
%   See also TISSOT, DISTORTCALC, VFWDTRAN

%   Copyright 1996-2003 The MathWorks, Inc.
%   Written by: W. Stumpf
%   $Revision: 1.5.4.2 $    $Date: 2003/08/01 18:18:55 $
%
%  Ref. Maling, Coordinate Systems and Map Projections, 2nd Edition, 

if nargin == 0
	
	h = findobj(gca,'Tag','DISTORTMlines');
	if isempty(h)
		action = 'maxscale';
		gsize = [];
	else
		mdistort off
		return
	end
	
elseif nargin < 3
	gsize = [];
elseif nargin > 3
	error('Incorrect number of arguments')
end

% Check that action is a string
if ~isstr(action); error('Argument must be a string'); end
action = lower(action);

% Check for recognized actions
actions = {'on','off','area','angles','angle','scale','maxscale','minscale','parscale','merscale','scaleratio'};

if isempty(strmatch(action,actions,'exact'))
	error('Unknown MDISTORT option')
end

switch action
case 'on'
	action = 'maxscale';
end

% Handle OFF case first. Return the name of the currently 
% plotted parameter for redisplay after a projection change.

switch action
case 'off'
	
	h = findobj(gca,'Tag','DISTORTMlines');
	ht= findobj(gca,'Tag','DISTORTMtext');
	
	param = [];
	if ~isempty(h)
		struct = getm(h(1));
		param = struct.parameter;
	end
	delete([h;ht])
	if nargout >= 1; hout = param;end
	if nargout == 2; htout = [];end
	
	return
	
end

% Construct a graticule within the frame limits and compute 
% distortion parameters at the graticule intersections. Using 
% the framelimits avoids clipping operations at the dateline.

% Get the map structure from the axes
mstruct = getm(gca);

% Issue a warning if projection is UTM
if strmatch(mstruct.mapprojection,'utm')
    warning('MDISTORT is not intended for use with UTM');
end

% Grid up the area within the frame

if ~any(isinf(mstruct.flatlimit)) % non-azimuthal frame
	
	[latgrat,longrat] = meshgrat(mstruct.flatlimit,mstruct.flonlimit,gsize);

else % azimuthal frame

	rnglim = mstruct.flatlimit;
	rnglim(1) = 0;
	epsilon = 100000*epsm('degrees');

	azlim = angledim([0+epsilon 360-epsilon],'degrees',mstruct.angleunits);
	
	[rnggrat,azgrat] = meshgrat(rnglim,azlim,gsize);
	[latgrat,longrat] = reckon('gc',0*rnggrat,0*rnggrat,rnggrat,azgrat,mstruct.angleunits);

end

	
% Reset the map to the base projection
mstruct.origin = [ 0 0 0];

% Compute the projection distortion parameters by finite differences
[areascale,angdef,maxscale,minscale,merscale,parscale] = ...
	distortcalc(mstruct,latgrat,longrat);

% Projected graticule coordinates
[xgrat,ygrat] = mfwdtran(mstruct,latgrat,longrat);

% Set up contour levels (for angles, see below)
if nargin < 2
	levels = [ 0 0.5 1 2 5 10 15 20 50 100  200 400 800]; 
	levels = [-fliplr(levels) levels]; % used for scale calculations
end

% Select requested parameter

switch action
case 'area'
	param = (areascale-1)*100; % in percent
case {'angles','angle'}
	if nargin < 2; levels = [ 0 0.5 1 2 5 10 20 30 45 90 180]; end
	param = angledim(angdef,mstruct.angleunits,'degrees'); % Convert angular deformation to degrees
case {'maxscale','scale'}
	param = (maxscale-1)*100; % in percent
case 'minscale'
	param = (minscale-1)*100; % in percent
case 'parscale'
	param = (parscale-1)*100; % in percent
case 'merscale'
	param = (merscale-1)*100; % in percent
case 'scaleratio'
	param = (abs(minscale./maxscale)-1)*100; % in percent
end

% Remove any previously plotted results

mdistort off

% Add contour lines and labels to the plot

ht = [];
if ~isempty(findstr(version,'R14'))
    [c,h] = contour('v6',xgrat,ygrat,param,levels);
else
    [c,h] = contour(xgrat,ygrat,param,levels);
end
if ~isempty(h); 
	tagm(h,'DISTORTMlines')

	ht = clabel(c,h);

	if ~isempty(ht)
		zdatam(ht,max(param(:)));
		set(ht,'color','r')

		tagm(ht,'DISTORTMtext')
	end
	
	s.clipped = []; s.trimmed = [];s.parameter = action;
	set([h;ht],'UserData',s)
end

% Set output arguments

if nargout >= 1; 
	switch action
	case 'off',
		hout = param; % used by SETM to redo lines when projection changes
	otherwise
		hout = h;
	end
end

if nargout == 2; htout = ht;end

