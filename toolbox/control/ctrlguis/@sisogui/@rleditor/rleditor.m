function h = rleditor(EditedModel,LoopData)
%RLEDITOR  Constructor for the Root Locus Editor.

%   Authors: P. Gahinet
%   Revised: A. DiVergilio
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.39 $ $Date: 2002/04/10 04:57:19 $

% Create class instance
h = sisogui.rleditor;

% Initialize properties 
h.EditedObject = EditedModel;
h.LoopData = LoopData;

% Root-locus specific properties
h.GridOptions = struct(...
    'GridLabelType','damping');
h.AxisEqual = 'off';

