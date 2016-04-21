function h = pzeditor(LoopData,Parent)
%PZEDITOR  Constructor for compensator pole/zero Editor.

%   Author(s): Karen Gondoly. 
%   Revised: P. Gahinet (OO implementation)
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.13 $  $Date: 2002/04/10 04:55:13 $

% Create class instance
h = sisogui.pzeditor;
h.LoopData = LoopData;
h.Parent = Parent;

% Fint size
h.FontSize = Parent.Preferences.UIFontSize;
h.FrequencyUnits = Parent.Preferences.FrequencyUnits;

% Install listeners
h.addlisteners;

