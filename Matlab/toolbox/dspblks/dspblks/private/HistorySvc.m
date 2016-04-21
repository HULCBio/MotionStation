function y = HistorySvc(varargin)
%HistorySvc Provide History services to Viewers
%   idx = HistorySvc('initialize', blkh, Nmax)
%      - initialize History service for this subscriber (block handle)
%        Nmax is maximum history to maintain
%      - if called again before service termination,
%        the index of the existing entry is returned,
%        with a minus sign to denote that the add failed
%
%   idx = HistorySvc('index', blkh)
%      Get database index for named entry
%
%   HistorySvc('change_max_hist', idx, Nmax)
%      - changes (extends or truncates) history length
%
%   HistorySvc('flush', idx)
%      - removes all data from history of this subscriber
%   HistorySvc('flush')
%      - removes all data for all subscribers
%
%   HistorySvc('store', idx, data)
%      - append new data to end of history
%
%   HistorySvc('replace', idx, data_cell)
%      - replaces all data in history with new data
%        one data item per cell array entry
%      - performs the equivalent of a flush before
%        storing new data
%
%   HistorySvc('retrieve', idx)
%     - returns all stored data, oldest data first
%   HistorySvc('retrieve', idx, N)
%   HistorySvc('retrieve', idx, N1:N2)
%     - return data from N1 to N2, returning a cell array of historical data
%          0  is the most recently stored (last) data
%          1  is the 2nd-to-last data stored
%          2, 3, ..., Nmax are historical values
%              Nmax is the max history
%          >= Nmax+1 returns NaN's
%         -1 is a synonym for oldest, Nmax
%         -2 is one earlier than oldest
%         -3, -4, ..., -Nmax-1 are more recent data values
%
%   HistorySvc('delete', idx)
%      - called when subscriber is done with service

% Copyright 1995-2002 The MathWorks, Inc.
% $Revision: 1.1 $  $Date: 2002/11/14 02:47:08 $

% Spec for internal storage:
%  - vector cell array, 
%    one cell array per subscriber,
%    one entry in cell array per data item stored
%  - adds newest data to end of buffer
%       {old newer newest}
%    or, using index notation,
%       {x[n-2] x[n-1] x[n]}
%  - unassigned entries are initialized to an empty matrix
%    which are indistinguishable from stored empty matrices
%    (this could be modified to allow arbitrary initialization
%     values supplied by the subscriber)
%  - uses circular buffer storage internally for quick writes
%    to memory,
%         { x[n-2] x[n-1] x[n] x[n-5] x[n-4] x[n-3] }
%    and retains index to the "next entry to overwrite",
%    e.g., the oldest current entry in the buffer.
%    In this example, index=4 (points to x[n-5]).
%  - Data extending over time is "linearized" when returned to caller,
%    oldest data first:
%      {x[n-5] x[n-4] x[n-3] x[n-2] x[n-1] x[n]}
%  - Data is expected to be in linear order when accepted from caller
%    as well.

% xxx PROFILE: we use cell array vs. array of structures,
%              cell array is slower
% for debug:
%fprintf('HistorySvc: "%s"\n', varargin{1});

if nargout==0,
    dbase(varargin{:});
else
    y = dbase(varargin{:});
end

% ---------------------------------------------------------------
function y = dbase(action,idx,data,newIdx)

% idx = dbase('initialize', blkh, NMax)
% dbase('delete')
% dbase('delete', idx)
% y = dbase('append', idx, data)  (optional full-checking)
% dbase('replace', idx, data)
% data = dbase('retrieve', idx)
% data = dbase('retrieve', idx, N)
% data = dbase('peek')
% dbase('change_size', idx, new_size)
% newLen = dbase('extend', idx)

persistent db;

switch action
    case 'append'
        % Append data item to end of a circular history buffer
        % Each db entry is one circular buffer
        %
        % Note: does not extend length of buffer, just uses
        %       (or overwrites) existing allocation.
        %
        % dbase('append', idx, data)
        
        nextIdx = db(idx).Index;
%         while (nextIdx < 0),
%             % xxx - block Simulink thread - needed?
%             pause(0);  % allow ctrl+c
%             nextIdx = db(idx).Index;
%         end
        db(idx).Data{nextIdx} = data;
        db(idx).Index = 1+mod(nextIdx,length(db(idx).Data));
        
        if nargout>0,
            % If caller asked for a LHS, we send a flag indicating
            % whether the buffer "is full", i.e., we just wrote the
            % last element in the *linear* buffer, regardless of whether
            % we're going to wrap around/extend/suspend/etc.
            y = ( db(idx).Index <= nextIdx);
        end

    case 'retrieve'
        % Get data associated with model, or all data
        %
        % data = dbase('retrieve', idx)
        % data = dbase('retrieve', idx, N)
        
        % Returns a cell array, even if a single entry in history
        % is requested.  This is because we can ask for multiple
        % entries with this function as well, and that requires
        % a cell.  We could special-case the scalar queries, but
        % it costs time.
        %
        % data is the desired relative index in history, relative
        % to the latest entry.  It is "0-based", according to the
        % following definition:
        %   Index   Entry
        %    0       x[n]  (most recent entry)
        %    1       x[n-1] (older)
        %    2       x[n-2] (even older)
        %    etc
        %
        % Note that nextIdx is the *next* entry to be filled, or
        % equivalently, the *oldest* entry in the buffer, and it
        % is a 1-based index.
        %
        % (nextIdx-1) is the *most recent* entry (1-based index)
        %
        % - Retrieving relative index 0 retrieves nextIdx-1.
        % - Retrieving relative index 1 retrieves nextIdx-2.
        %
        % Deal with desired indices that have "wrapped"
        % Equivalent code, but doesn't handle more than one wrap
        %   getIdx = nextIdx-1-data;
        %   if getIdx<1, getIdx=getIdx+lenData; end
        
        y = db(idx).Data;
        nextIdx = abs(db(idx).Index);  % next avail index
        lenData = length(y);
        if nargin<3,
            data = lenData-1:-1:0; % get all data from oldest to most recent
        else
            data = round(data);  % in case non-integer indices passed
        end
        y = y(1+mod(nextIdx-2-data,lenData));
                
    case 'getPos'
        y = db(idx).Index;
        
        % Now block (or unblock) 'append' threads by reversing
        % sign of index.  First call to this method blocks,
        % second call unblocks.
        %
        % xxx needed?
        % db(idx).Index = -db(idx).Index;
        
    case 'initialize'
        % Add entry to database and initialize data
        % The entry will have a block handle, and a circular buffer
        % of storage with NMax (empty) elements
        %
        % dbase('add', blkh, NMax)
        
        % If entry exists, keep it and re-initialize data
        blkh = idx;  % user passes a block handle, not an index
        idx  = [];   % we want to find this
        if ~isempty(db),
            % Try to find an existing entry if dbase not empty
            idx = find(blkh == [db.Block]);
            if length(idx)>1,
                error('Waterfall:BadHistoryIndex', ...
                    'More than one matching history service entry.');
            end
        end
        if isempty(idx),
            idx = getNewIndex(db);
        end
        % create data structure
        s.Block = blkh;
        s.Index = 1; % next index to read from
        s.Data = cell(1,data);  % data = NMax, max # of entries in circ buff
        
        % Determine where to put this
        if isempty(db),
            db = s;
        else
            db(idx) = s;
        end
        y = idx;  % return new index into database
        
                
    case 'replace'
        %replace all existing data with new data
        % assumes that data is a cell-array
        if ~iscell(data),
            error('Data history must be passed as a cell-array');
        end
        % leave .Block as it is
        db(idx).Data  = data; % replace all data
        db(idx).Index = newIdx;   % reset circular buffer index
        
    case 'delete'
        % Delete entire database, or
        % Delete one client (block) from database
        %
        if nargin<2,
            % entire database:
            db = struct([]);
        else
            %  delete specific entry:
            if ~isempty(db) && ~isempty(idx),
                % Reset entry, leave for garbage collection
                db(idx).Data  = [];
                db(idx).Index = [];
                db(idx).Block = [];
            end
        end
        
    case 'flush'
        if ~isempty(db),
            % replace existing data with empty cells
            % If idx did not exist, it is created
            db(idx).Data  = cell(1,length(db(idx).Data));
            db(idx).Index = 1;   % reset circular buffer index
        end
        
    case 'change_size'
        % Change size of the circular buffer for subscriber
        % Steps:
        %  1 Retrieve linearized data,
        %  2 extend/truncate cells
        %  3 overwrite old history with new
        %
        newLen = data;
        oldLen = length(db(idx).Data);
        if newLen ~= oldLen,
            data = dbase('retrieve',idx);  % linear order, oldest first
            if oldLen < newLen,
                % New history is longer than prior history, so we
                % extend data by PREPADDING with "zero" history items.
                % (Remember, oldest data appears first in history cell array)
                %data = [cell(1,newLen-oldLen) data];
                %newIdx = 1;  % oldest cell
                
                % extend data by POSTPADDING with empties for new future
                % items.  Oldest data appears first in history cell array,
                % so new empties go at end.  We point index to the first of
                % these new empties as well.
                data = [data cell(1,newLen-oldLen)];
                newIdx = oldLen+1;
                
                % xxx Debug:
                %fprintf('historySvc: extend: newIdx=%d, existing .Index=%d\n', ...
                %    newIdx, db(idx).Index);
                
            else % newLen < oldLen
                % remove oldest data, which appears FIRST in history cell array
                data = data(end-newLen+1:end);
                newIdx = 1;
            end
            db(idx).Data  = data;    % replace all data
            db(idx).Index = newIdx;  % reset circular buffer index
        end
        
    case 'extend'
        % Extend the buffer allocation, 
        % Simply calls 'change_size', but first
        % determines next larger buffer size to use
        %
        % Algorithm: double the last allocation, but subtract
        % off quantity indicated by caller.
        oldLen = length(db(idx).Data);
        y = data+2*(oldLen-data);  % new length, data is reduction amount from user
        dbase('change_size', idx, y);
        
    case 'peek'
        y = db;
        
    otherwise
        error('Unrecognized database method');
end


% ---------------------------------------------------------------
function newIdx = getNewIndex(db)
%GetNewIndex Finds an index into database to store a new entry.
%   If a previously-terminated entry exists, reuse it.
%     (We recognize these as having an empty name string.)
%   Otherwise, give index to end of database

N = length(db);  % could be empty
for i=1:N,
    if isempty(db(i).Block),
        newIdx = i;
        return
    end
end
newIdx = N+1;

% [EOF] $File: $
