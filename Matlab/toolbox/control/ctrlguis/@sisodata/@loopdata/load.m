function load(LoopData,SavedData)
%LOAD   Reloads loop data from previous session.
%
%   See also SISOTOOL.

%   Author(s): P. Gahinet
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.7 $  $Date: 2002/04/10 04:53:21 $

% Clear dependencies
LoopData.reset('all');

% Import data to LoopData (error-free)
LoopData.importdata(...
    SavedData.Plant,SavedData.Sensor,SavedData.Filter,SavedData.Compensator);

% Updated system name, feedback sign, and loop configuration
LoopData.SystemName = SavedData.SystemName;
LoopData.FeedbackSign = SavedData.FeedbackSign;
LoopData.Configuration = SavedData.Configuration;

% Restore saved designs
LoopData.SavedDesigns = SavedData.SavedDesigns;


