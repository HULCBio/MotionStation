function A = updatemenu(A)
%AXISOBJ/UPDATEMENU Update menu for axisobj
%   This file is an internal helper function for plot annotation.

%   Copyright 1984-2004 The MathWorks, Inc. 
%   $Revision: 1.10.4.1 $  $Date: 2004/01/15 21:11:51 $

HG = get(A,'MyHGHandle');

menu = get(A,'UIContextMenu');
movemenu = findall(menu,'Tag','ScribeAxisObjMoveResizeMenu');

checked = {'off' 'on'};
legendLabel = {'Show Le&gend' 'Hide Le&gend'};
lockLabel =  {'Unloc&k Axes Position' 'Loc&k Axes Position'};
set(movemenu,...
        'Checked','off',...
        'Label',lockLabel{get(A,'Draggable')+1})

% look for a legend on this axis
% any children?
legendmenu = findall(menu,'Tag','ScribeAxisObjShowLegendMenu');
if length(get(HG,'Children'))==0
   set(legendmenu,...
           'Enable',checked{0+1},...
           'Label',legendLabel{0+1});   
else
   set(legendmenu,...
           'Enable',checked{1+1},...
           'Label',legendLabel{islegendon(HG)+1});
end

   

