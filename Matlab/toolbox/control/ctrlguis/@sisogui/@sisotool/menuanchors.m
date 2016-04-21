function MenuAnchors = menuanchors(sisodb)
%MENUANCHORS  Points of attachment for editor menus.

%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.4 $ $Date: 2002/04/10 05:00:16 $

% Determine anchor for editor's context menu in figure menus
EditMenu = sisodb.HG.Menus.Edit;
MenuAnchors = [...
        EditMenu.Rlocus ; ...
        EditMenu.BodeOL ; ...
        EditMenu.Nichols ; ...
        EditMenu.BodeF ];

