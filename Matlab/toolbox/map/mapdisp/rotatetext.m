function rotatetext(h,direction)

%ROTATETEXT rotates text to the projected graticule
% 
%   ROTATETEXT rotates displayed text objects to account for the curvature of 
%   the graticule.  The objects are selected interactively from a graphical 
%   user interface.
%   
%   ROTATETEXT(objects) rotates the selected objects.  objects may be a name 
%   string recognized by HANDLEM, or a vector of handles to displayed text 
%   objects.
%   
%   ROTATETEXT(objects,'inverse') removes the rotation added by an earlier use 
%   of ROTATETEXT.  If omitted, 'forward' is assumed.
%
%   Meridian and parallel labels can be rotated automatically setting the 
%   map axes LabelRotation property to on.
%   
%   See also VFWDTRAN, VINVTRAN

% Copyright 1996-2003 The MathWorks, Inc.
% $Revision: 1.5.4.1 $  $Date: 2003/08/01 18:22:35 $


if nargin == 0
	h = handlem;
	direction = 'forward';
elseif nargin == 1;
	direction = 'forward';
elseif nargin ~=2
	error('Incorrect number of arguments')
end

% get h as handles
if isstr(h);
	h = handlem(h);
end

if ~ishandle(h);
	error('Object must be a name string or handle')
end

% check for recognized directions

directions = {'forward','inverse'};

if isempty(strmatch(direction,directions,'exact'))
	error('ROTATETEXT ''forward'' or ''inverse''')
end

switch direction
case 'forward'
	forward = 1;
case 'inverse'
	forward = 0;
end

% aligntext?

if isstr(h); h= handlem(h); end

% open limits to avoid bumping against the frame. 

mstruct = gcm; 
mstruct.maplatlimit	= [-90 90];
mstruct.maplonlimit	= [-180 180];
mstruct.flatlimit	= [-90 90];
mstruct.flonlimit	= [-180 180];

% calculate vector rotatation introduced by the projection

for i=1:length(h)
	type = get(h(i),'Type');
	switch type
	case 'text'
		pos = get(h(i),'position');
		[lat,lon] = minvtran(pos(1),pos(2));
		th = vfwdtran(mstruct,lat,lon,90);
		rot = get(h(i),'Rotation');
		if forward
			set(h(i),'rotation',th+rot);
		else
			set(h(i),'rotation',-th+rot);
		end
	end
end




