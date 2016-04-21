function wrapper = getWorkspaceWrapper(workspace)

    mlock;

    if (nargin == 0)
        workspace = 'base';
    end

    wrapper = archive_l(workspace);

    if isempty(wrapper)
        if ischar(workspace) & strcmp(workspace, 'base')
            wrapper = DAStudio.WorkspaceWrapper;
        else
            wrapper = DAStudio.WorkspaceWrapper(workspace);
        end
        archive_l(workspace, wrapper);
    end

    wrapper = java(wrapper);

function out = archive_l(key, value)
    persistent keys;
    persistent values;
    persistent base;

    out = [];

    if nargin == 1
        if ischar(key) & strcmpi(key, 'base')
            out = base;
        elseif ~isempty(keys)
            out = values(keys==key);
        end
    else
        if ischar(key) & strcmpi(key, 'base')
            base = value;
        elseif isempty(keys)
            keys = key;
            values = value;
        else
            keys(end+1) = key;
            values(end+1) = value;
        end
    end


%   Copyright 2002-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:32:13 $
