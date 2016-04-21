function [entry, errflag] = privateUpdateEntry(entry, cobject, value)
%PRIVATEUPDATEENTRY Update a configuration store entry with the specified structure.
% 

%   PE 10-01-03
%   Copyright 1999-2004 The MathWorks, Inc. 
%   $Revision: 1.1.6.3 $  $Date: 2004/02/01 21:55:11 $

% Type is used internally by the object, but is not part of the COM object.
value = rmfield(value, 'Type');

names = fieldnames(value);

errflag = false;

for idx = 1:length(names)
    switch (names{idx})
        case 'HardwareAsset'
            c = privateGetNamedEntry(cobject.HardwareAssets, value.(names{idx}), true);
            if (~isempty(c))
                entry.(names{idx}) = c;
            else
                errflag = true;
                lasterr([value.(names{idx}) ' is not a valid HardwareAsset entry in the configuration store.']);
                return;
            end
        case 'SoftwareModule'
            c = privateGetNamedEntry(cobject.SoftwareModules, value.(names{idx}), false);
            if (~isempty(c))
                entry.(names{idx}) = c;
            else
                errflag = true;
                lasterr([value.(names{idx}) ' is not a valid SoftwareModule entry in the configuration store.']);
                return;
            end
        case 'Session'
            c = privateGetNamedEntry(cobject.Sessions, value.(names{idx}), false);
            if (~isempty(c))
                entry.(names{idx}) = c;
            else
                errflag = true;
                lasterr([value.(names{idx}) ' is not a valid Session entry in the configuration store.']);
                return;
            end
        case 'VirtualNames'
            % Remove any old virtual names.
            for idx=entry.VirtualNames.Count:-1:1
                entry.VirtualNames.Remove(idx);
            end
            for idx = 1:length(value.VirtualNames)
                vname = actxserver('IviConfigServer.IviVirtualName');
                vname.Name = value.VirtualNames(idx).Name;
                vname.MapTo = value.VirtualNames(idx).MapTo;
                entry.VirtualNames.Add(vname);
            end
        otherwise
            entry.(names{idx}) = value.(names{idx});
    end
end

