function A = updatemenu(A)
%EDITLINE/UPDATEMENU  Update context menus for editline objects
%   This file is an internal helper function for plot annotation.

%   Copyright 1984-2004 The MathWorks, Inc. 
%   $Revision: 1.7.4.1 $  $Date: 2004/01/15 21:12:24 $

menu = get(A,'UIContextMenu');

% update style selection
lineStyle = get(A,'LineStyle');
% menu children are listed in reverse order!
styles = {...
   '-.','dashdot',
   ':','dot',
   '--','dash',
   '-','solid',
   };

styleMenu = findall(menu,'Tag','ScribeEditlineObjStyleMenu');
submenus = allchild(styleMenu);
whichStyle = find(strcmp(lineStyle,styles(:,1)));

set(submenus,'Checked','off');
set(submenus(whichStyle),'Checked','on');


% update size selection
lineSize = get(A,'LineWidth');
% menu children are listed in reverse order!
% first entry is a placeholder for the "more" option
sizes = [...
   0
   10
   9
   8
   7
   6
   5
   4
   3
   2
   1
   0.5
   ];

sizeMenu = findall(menu,'Tag','ScribeEditlineObjSizeMenu');
submenus = allchild(sizeMenu);
whichSize = find(lineSize==sizes);

set(submenus,'Checked','off');
set(submenus(whichSize),'Checked','on');
