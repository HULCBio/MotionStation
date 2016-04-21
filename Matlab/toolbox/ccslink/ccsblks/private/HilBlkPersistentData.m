function varargout = HilBlkPersistentData(varargin)
% This function encapsulates persistent data for use with
% HIL Block.  Each instance of the block has its own
% copies of the data, and all are stored here.  
%
% Syntax:
% P = HilBlkPersistentData(blk,'get')      Retrieves previous value.
%     HilBlkPersistentData(blk,'set',val)  Sets storage to new value.
%     HilBlkPersistentData(blk,'clear')    Clears all data for this block.
%     HilBlkPersistentData(blk,'clearall') Clears all data for all blocks.
%
% When using this information in other m-files, I call it 
% "PDATA", where "P" is for persistent variable, which does 
% not persist between sessions but does between m-functions. 
% This is in contrast with "UDATA", which does persist between
% sessions.  This nomenclature is misleading but consistent.

% Copyright 2003-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2004/04/08 20:44:46 $

blkName = varargin{1};
if isnumeric(blkName),
    error('HilBlkPeristentData.m requires a block name, not a handle.')
end
action    = varargin{2};

persistent blkNames PersistData

if strcmp(action,'clearall'),
    
    blkNames = {};
    PersistData = {};
    
else
    
    % First, find index of this block; if not encountered yet, save it.
    found = -1;
    for k = 1:length(blkNames),
        if strcmp(blkNames{k},blkName),
            found = k;
            break;
        end
    end
    if found>0,
        blkIdx = found;
    else
        % Not found; register this block.
        blkNames{end+1} = blkName;
        blkIdx = length(blkNames);
        PersistData{blkIdx} = getBlankPdata; 
    end
    
    % Now that we have a blkIdx, 
    % perform requested operation.
    switch action
        
        case 'clear',
            PersistData{blkIdx} = getBlankPdata;
            
        case 'get',
            val = PersistData{blkIdx};
            varargout{1} = val;
            
        case 'set',
            val = varargin{3};
            PersistData{blkIdx} = val;
            
    end
    
end

% -------------------------------------------
function p = getBlankPdata

p.ccsObj = []; 
p.ccsObjStale = true;
p.tgtFcnObj = [];
p.tgtFcnObjStale = true;
p.tgtFcnObjFullyDeclared = false;
p.numInports = 0;
p.numOutports = 0;
p.inports = [];
p.outports = [];
