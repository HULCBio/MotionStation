function newName = renameObject(h, oldName, newName)

    valid = h.validateNewNames({newName});

    newName = valid{1};

    if ~isempty(newName)
        if (isempty(h.wrappedWorkspace))
            ws = 'base';
        else
            ws = h.wrappedWorkspace;
        end

        value = evalin(ws, oldName);
        evalin(ws, ['clear ', oldName]);
        assignin(ws, newName, value);

        if ~isempty(h.jCache)
            cache = java(h.jCache);
            workspaceObject = handle(cache.remove(oldName));
            if ~isempty(workspaceObject)
                workspaceObject.Name = newName;
                cache.put(newName, java(workspaceObject));
                if workspaceObject.Object.isa('DAStudio.MXArray')
                    workspaceObject.Object.name = newName;
                end
            end
        end

    end


%   Copyright 2002-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:31:39 $
