function store(LoopData,Name)
%STORE  Stores compensator design and associated data.
%
%   See also SISOTOOL.

%   Author(s): P. Gahinet
%   Copyright 1986-2002 The MathWorks, Inc.
%   $Revision: 1.12 $  $Date: 2002/04/10 04:54:17 $

% Save and name C and F

SavedDesigns = LoopData.SavedDesigns;
C = LoopData.Compensator.save;
C.Name = sprintf('%s_C',Name);
F = LoopData.Filter.save;
F.Name = sprintf('%s_F',Name);

% Add design to list
CurrentDesign = struct(...
    'Name',Name,...
    'Configuration',LoopData.Configuration,...
    'FeedbackSign',LoopData.FeedbackSign,...
    'Plant',LoopData.Plant.save,...
    'Sensor',LoopData.Sensor.save,...
    'Filter',F,...
    'Compensator',C);

ind = find(strcmpi(Name,{SavedDesigns.Name}));

% Update design history
% RE: Do not add to undo list (makes it impossible to save comp. before undoing some steps)

if ~isempty(ind)
    LoopData.SavedDesigns = [SavedDesigns(1:ind-1); CurrentDesign; SavedDesigns(ind+1:end)];
else
    LoopData.SavedDesigns = [SavedDesigns; CurrentDesign];
end
