function result = truth_table_handle_man(method, varargin)

% Copyright 2003 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2004/04/15 01:01:15 $

persistent handleCache;

defaultCapacity = 6;

if isempty(handleCache)
    handleCache = get_template_entry;
    handleCache(1:defaultCapacity) = get_template_entry;
    
    mlock;
end

result = [];

if ~jvmAvailable
    str = sprintf('%s','Stateflow Truthtable editor requires Java Swing and AWT components. One of these components in missing.');
    warning(str);
    return;
end

switch method
    case 'capacity'
        if nargin > 1
            newCapacity = varargin{1};
            handleCache = set_cache_capacity(handleCache, newCapacity);
        end
        result = length(handleCache);
    case 'close'
        ttId = varargin{1};
        handleCache = close_handle(handleCache, ttId);
    case 'open'
        ttId = varargin{1};
        predTbl = varargin{2};
        actTbl = varargin{3};
        handleCache = open_handle(handleCache, ttId, predTbl, actTbl);
        result = handleCache(1).handle;
    case 'get'
        ttId = varargin{1};
        result = get_handle_by_id(handleCache, ttId);
    case 'status'
        stat.status = [handleCache.status];
        stat.id     = [handleCache.id];
        result = stat;
    case 'touch'
        ttId = varargin{1};
        index = find_cache_entry_with_id(handleCache, ttId);
        if index > 0
            handleCache = touch_cache(handleCache, index);
        end
    otherwise
        str = sprintf('Unknown method ''%s'' for truth_table_handle_man.', method);
        warning(str);
end
        
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function templateEntry = get_template_entry
% status: 2: handle loaded (hidden)
%         1: vacant
%         0: actively in use (visible)

templateEntry.id = 0;
templateEntry.handle = [];
templateEntry.status = 1;
templateEntry.touched = 0;

return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function tof = jvmAvailable

tof = usejava('jvm') & usejava('awt') & usejava('swing');
return;
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function cache = set_cache_capacity(cache, newCap)

minCacheCapacity = 3;   % Minimum cache capacity
maxCacheCapacity = 16;  % Maximum cache capacity

capacity = length(cache);
newCap = max(minCacheCapacity, min(newCap, maxCacheCapacity));

if newCap > capacity
    padding = get_template_entry;
    padding(1:(newCap - capacity)) = get_template_entry;
    cache = [cache padding];
elseif newCap < capacity
    for i = (newCap+1):capacity
        if cache(i).status == 0 % Actively in use
            truth_table_man('destroy_ui_side_effect', cache(i).id);
        end
        
        if ~isempty(cache(i).handle)
            cache(i).handle.closeEditor;
        end
        
        cache(i).handle = [];
    end

    cache = cache(1:newCap);
end

return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function cache = sort_cache_entries(cache)
% Sort cache entries, so that the most recently used handle always at left

weights = [];
len     = length(cache);
modVal  = len + 1;

for i = 1:len
    offset = i;
    if cache(i).touched
        offset = 0;
        cache(i).touched = 0;
    end
    weights(i) = cache(i).status * modVal + offset;
end

[sorted, mapping] = sort(weights);
cache = cache(mapping);

return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function index = find_cache_entry_with_id(cache, objectId)
% Find the active cache entry for object with "objectId"

index = 0;

for i = 1:length(cache)
    if cache(i).status == 0 && cache(i).id == objectId
        index = i;
        break;
    end
end

return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function handle = get_handle_by_id(cache, objectId)
% Return the UI handle of objectId

handle = [];
index = find_cache_entry_with_id(cache, objectId);
if index > 0
    handle = cache(index).handle;
end

return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function cache = close_handle(cache, objectId)
% Close the UI for "objectId" by making UI invisible

index = find_cache_entry_with_id(cache, objectId);
if index > 0
    cache(index).status = 2;               % Hidden status
    cache(index).id = 0;
    
    cache = touch_cache(cache, index);
end

return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function cache = open_handle(cache, objectId, predTable, actTable)
% Open UI handle for objectId.

index = find_cache_entry_with_id(cache, objectId);

if index == 0  % Not opened
    index = length(cache);  % Always get the least used entry (right most)
    reusedHandle = 0;
            
    switch cache(index).status
        case 0  % Actively in use
            truth_table_man('destroy_ui_side_effect', cache(index).id);
            reusedHandle = 1;
        case 1  % vacant
            import com.mathworks.toolbox.stateflow.truthtable.*;
            cache(index).handle = TruthTableEditor(objectId, predTable, actTable);
        case 2  % Hidden
            reusedHandle = 1;
    end
    
    if reusedHandle
        cache(index).handle.setObjectId(objectId);
        cache(index).handle.updatePredicateTableEditor(predTable);
        cache(index).handle.updateActionTableEditor(actTable);
    end
    
    cache(index).id = objectId;
    cache(index).status = 0;  % Actively in use
end

cache = touch_cache(cache, index);
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function cache = touch_cache(cache, index)
% Touch the cache to resort

cache(index).touched = 1;
cache = sort_cache_entries(cache);
return;
