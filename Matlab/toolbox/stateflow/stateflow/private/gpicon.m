function gpicon(command, handle, bmp)
%GPICON( COMMAND, HANDLE, BMP)

%   E.Mehran Mestchian
%   Jay R. Torgerson
%   Copyright 1995-2002 The MathWorks, Inc.
%   $Revision: 1.11.2.1 $  $Date: 2004/04/15 00:58:15 $

if nargin==0, return; end

if any(size(bmp)~=[32,32])
	warning('Bad Stateflow icon press button bitmap!');
	return
end

hitType = get(handle,'type');
if ~strcmp(hitType,'surface'),
	if ~strcmp(hitType,'axes'),	warning('Bad icon handle!'); end;
	return
end;

switch command
	case 'press',
		v=4:28;
		center = bmp(v,v);
		bmp = fliplr(bmp);
		bmp = flipud(bmp);
		bmp(v+1,v+1) = center;

		dark  = bmp==9;
		light = bmp==2;
		black = bmp==1;

%		bmp(dark)  = 2;   %swap shadows
%		bmp(light) = 4;
%		bmp(1:31, 1) = 1; %swap black for light border
%		bmp(1, 1:32) = 1;
%		bmp(31,2:31) = 2; 
%		bmp(2:31,32) = 2;
%		bmp(2,2:31)  = 4;
%		bmp(3,2:30)  = 4;
%		bmp(5:30,5:29) = bmp(4:29,4:28); %jog 1 over 1 down
%		bmp(4:29,4) = 4; %paint in open space after jog
%		bmp(31,2)   = 4;
%		bmp(30,3)   = 4;
%		bmp(4:29,29:30) = 3;
	case 'release'
	otherwise,
		error('Bad command.');
end

set(handle,'CData',bmp);
