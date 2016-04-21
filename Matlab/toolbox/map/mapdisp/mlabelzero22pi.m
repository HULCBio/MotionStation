function mlabelzero22pi

% MLABELZERO22PI  Meridian labels in the range of 0 to 360 degrees
% 
%   MLABELZERO22PI displays meridan labels in the range of 0 to 360 degrees
%   east of the Prime Meridian.
%
%   Example
%     figure('color','w');
%     axesm('miller','grid','on');
%     tightmap; mlabel on; plabel on
%     mlabelzero22pi
%
%   See also MLABEL.

%  Copyright 1996-2003 The MathWorks, Inc.
%  Written by: L. Job
%  $Revision: 1.2.4.1 $  $Date: 2003/08/01 18:18:59 $

% check if a valid map axes is open
hndl = get(get(0,'CurrentFigure'),'CurrentAxes');
if isempty(hndl);  
    return;  
end

% check if the current axes is a map axes
if ~ismap(gca)
    return;
end

% check if Meridian labels are shown
h = handlem('MLabel');
if isempty(h)
    return;
end

str = get(h,'String');
if iscellstr(str)
    str = char(str);
end
str = deblank(str);

mapstruct = gcm;

% replace strings
switch mapstruct.labelformat
case 'compass'
	for i = 1:size(str,1)
        indx = findstr(str(i,:),'^');
        valstr = str(i,1:indx-1);
        switch lower(str(i,end))
        case 'w'
            valstr = ['-' valstr];
            val = 360+str2num(valstr);
            valstr = [num2str(val) '^{\circ} E'];
        case 'e'
            valstr = ['+' valstr];
            val = str2num(valstr);
            valstr = [num2str(val) '^{\circ} E'];
        end
        set(h(i),'String',valstr)
	end    
case 'signed'
	for i = 1:size(str,1)
        indx = findstr(str(i,:),'^');
        valstr = str(i,1:indx-1);
        val = str2num(valstr);
        valsign = '+';
        if val<0
            val = 360+val;
        end
        valstr = [valsign num2str(val) '^{\circ}'];
        set(h(i),'String',valstr)
	end    
case 'none'
	for i = 1:size(str,1)
        indx = findstr(str(i,:),'^');
        valstr = str(i,1:indx-1);
        val = str2num(valstr);
        if val<0
            val = 360+val;
        end
        valstr = [num2str(val) '^{\circ}'];
        set(h(i),'String',valstr)
	end    
end
