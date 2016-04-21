function h = bodeditorF(EditedModel,LoopData)
%BODEDITORF  Constructor for the PreFilter Bode Editor.

%   Author(s): P. Gahinet
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.10 $ $Date: 2002/04/10 05:03:38 $

% Create class instance
h = sisogui.bodeditorF;

% Set external dependencies
h.EditedObject = EditedModel;
h.LoopData = LoopData;




