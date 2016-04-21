function A = updatemenu(A)
%AXISTEXT/UPDATEMENU Update menu for axistext object
%   This file is an internal helper function for plot annotation.

%   Copyright 1984-2004 The MathWorks, Inc. 
%   $Revision: 1.7.4.1 $  $Date: 2004/01/15 21:12:06 $

menu = get(A,'UIContextMenu');

checked = {'off' 'on'};

% update size selection
fontSize = get(A,'FontSize');

sizeMenu = findall(menu,'Tag','ScribeAxistextObjSizeMenu');
submenus = allchild(sizeMenu);
set(submenus,'Checked','off');
whichMenu = findall(submenus,'Label', num2str(fontSize));
set(whichMenu,'Checked','on');


% update style selection
fontStyle = get(A,'FontAngle');
fontWeight = get(A,'FontWeight');

isBold = strcmp(fontWeight,'bold');
isItalic = strcmp(fontStyle,'italic');
isNormal = ~isBold & ~isItalic;

styleMenu = findall(menu,'Tag','ScribeAxistextObjStyleMenu');
submenus = allchild(styleMenu);

% menu order: normal, italic, bold
% menu children are listed in reverse order!

checks = {...
        checked{isBold+1}
        checked{isItalic+1}
        checked{isNormal+1}
        };

set(submenus,{'Checked'},checks);
