function out = getCachedObject(h, name)

    out = [];

    if isempty(h.jCache)
        cache = java.util.Hashtable;
        h.jCache = handle(cache);
    else
        cache = java(h.jCache);
    end

    out = handle(cache.get(name));
    if isempty(out)
        out = DAStudio.WorkspaceObject;
        out.Name = name;
        cache.put(name, java(out));
    end


%   Copyright 2002-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:31:36 $
