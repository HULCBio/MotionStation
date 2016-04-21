function h = tooldlg(ContainerList)
%TOOLDLG  Constructor for @tooldlg class.

%   Authors: Bora Eryilmaz
%   Revised:
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.3 $ $Date: 2002/04/10 05:06:49 $

% Create constraint editor instance.
h = sisogui.tooldlg;

% Initialize Container list.
h.ContainerList = ContainerList;
