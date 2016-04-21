function SyncSimulinkIO(this);
%%Syncs the IOs of the Simulink model.

%  Author(s): John Glass
%  Revised:
% Copyright 1986-2003 The MathWorks, Inc.
% $Revision: 1.1.6.1 $ $Date: 2003/12/04 01:34:47 $

%% Get the user defined IO Condition state
newios = getlinio(this.Model);
%% Get the state from the GUI
oldios = this.IOData;

%% Get the block names for comparision
oldblocknames = get(oldios,{'Block'});
newblocknames = get(newios,{'Block'});

%% Find the intersection
[commonblocks,ia,ib] = intersect(oldblocknames,newblocknames);

%% Create indicies to work with
indold = 1:length(oldios);
indnew = 1:length(newios);

%% Remove the intersecting IOs from the indecies
indnew(ib) = [];

%% Find the old IO points that are not active and are not in the current
%% Simulink diagram
indold(ia) = [];
%% Old ios that are not in the new IOs list
nonoldios = oldios(indold);
%% Create empty non-active IO list
nonactive = [];
%% Loop over nonoldios to find non-active ones
for ct = 1:length(nonoldios)
    if strcmp(nonoldios(ct).Active,'off')
        nonactive = [nonactive;nonoldios(ct)];
    end
end

%% Create the new IO list
this.IOData = [newios(sort(ib));nonactive;newios(indnew)];