function h = nicholseditor(EditedModel, LoopData)
%NICHOLSEDITOR  Constructor for the Nichols Plot Editor.

%   Author(s): Bora Eryilmaz
%   Revised:
%   Copyright 1986-2002 The MathWorks, Inc.
%   $Revision: 1.11 $ $Date: 2002/04/10 05:05:02 $

% Create class instance
h = sisogui.nicholseditor;

% Initialize properties 
h.EditedObject = EditedModel;
h.LoopData = LoopData;
