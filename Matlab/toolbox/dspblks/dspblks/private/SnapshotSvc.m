function SnapshotSvc(varargin)
%SnapshotSvc Provide SnapShot and Suspend services to viewers
%   SnapshotSvc('init', handle)
%      - initialize SnapShot/Suspend service for this subscriber
%   SnapshotSvc('terminate', handle)
%      - called when subscriber is done with service
%   SnapshotSvc('reset')
%      - clears entire database
%   SnapshotSvc('syncsnapshot', handle, freezeMode, isSync)
%      - synchronized freeze/unfreeze of all blocks
%        in database, where freezeMode is 'on' or 'off'

% Copyright 1995-2002 The MathWorks, Inc.
% $Revision: 1.1 $  $Date: 2002/11/14 02:47:07 $

feval(varargin{:});

% ---------------------------------------------------------------
function init(blkh)
% add one model to database
dbase('add',bdroot(blkh));

% ---------------------------------------------------------------
function terminate(blkh)
% terminate for one model
dbase('clear',bdroot(blkh));

% -------------------------------------------------------------------------
function syncupdate(blkh, prop, val)
% Perform Synchronized Snapshots
% That is, freeze or un-freeze all snapshot-capable scopes
%   according to freezeMode ('on' freezes, 'off' unfreezes)
%
% Prop is either 'Snapshot' or 'Suspend'

allBlksInModel = dbase('retrieve', bdroot(blkh));
for i=1:length(allBlksInModel),
    set_param(allBlksInModel(i),prop,val);
end
%set_param(allBlksInModel,prop,val);  % SL not vectorized

% ---------------------------------------------------------------
function blks = FindAllSnapshotBlocks(model)
% Find all sink blocks with snapshot capabilities

% Basically, find all masks that have both the mask parameters
% 'SyncSnapshots' and 'Snapshot'.
% These parameters are set to either 'on' or 'off', making 'o' a nice
% character to search for in the corresponding values.
%
blks = find_system(model,'regexp','on', ...
    'followlinks','on', ...
    'lookundermasks','all', ...
    'Snapshot','o', ...
    'SyncSnapshots','o');

% ---------------------------------------------------------------
function y = dbase(action,modelHandle)
% dbase('add', model) adds model to database, and computes all
%     blocks with snapshot services in that model
%
% dbase('clear') clears entire database
% dbase('clear',model) clears database for model
%
% dbase('retrieve', model) returns entry for model
% dbase('retrieve') returns entire database

persistent data;

switch action
    case 'add'
        % Is ModelName already in database?
        alreadyPresent=0;
        if ~isempty(data),
            alreadyPresent = any([data.ModelHandle] == modelHandle);
        end
        if ~alreadyPresent,
            % We wish to compute and store one list of blocks that offer snapshot services
            % in the model, just once per model due to the expense of computing this list.
            % It's the same list throughout the simulation, since blocks cannot change.
            s.ModelHandle = modelHandle;
            s.SnapshotBlks = FindAllSnapshotBlocks(modelHandle);
            if isempty(data),
                data = s;
            else
                data(end+1) = s;
            end
        end
        
    case 'clear'
        % clear database - for given model, or entirely
        if nargin<2,
            % entire database:
            data = struct([]);
        else
            %  clear entry for specific model:
            if ~isempty(data),
                idx = find([data.ModelHandle] == modelHandle);
                if ~isempty(idx),
                    data(idx)=[];  % remove entry
                end
            end
        end
        
    case 'retrieve'
        % get data associated with model, or all data
        if nargin<2,
            y = data;
        else
            if isempty(data), y=[]; return; end
            
            idx = find([data.ModelHandle] == modelHandle);
            if isempty(idx),
                y = [];  % if not found, return with empty hands
                return
                % error('No Snapshot entry for model "%s"', modelName);
            end
            y = data(idx).SnapshotBlks;
        end
        
    otherwise
        error('Unrecognized database method');
end

% [EOF] $File: $
