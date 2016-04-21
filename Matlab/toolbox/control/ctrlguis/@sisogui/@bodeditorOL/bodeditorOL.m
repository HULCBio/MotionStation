function h = bodeditorOL(EditedModel,LoopData)
%BODEDITOROL  Constructor for the Open-Loop Bode Editor.

%   Author(s): P. Gahinet
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.8 $ $Date: 2002/04/10 05:02:42 $

% Create class instance
h = sisogui.bodeditorOL;

% Set external dependencies
h.EditedObject = EditedModel;
h.LoopData = LoopData;

