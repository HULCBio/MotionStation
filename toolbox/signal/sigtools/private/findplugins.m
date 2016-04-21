function plugins = findplugins(filename)
%FINDPLUGINS Finds plug-ins

%   Author(s): P. Pacheco, J. Schickler
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.5.4.4 $  $Date: 2004/04/13 00:32:35 $

[p, filename, ext] = fileparts(filename);
if isempty(ext), ext = '.m'; end

filename = [filename ext];

all_plugins = which('-all',filename);
[p, filename, ext] = fileparts(filename);

plugins     = {};

for i = 1:length(all_plugins)

    % Open the file
    fid  = fopen(all_plugins{i}, 'r');
    if fid ~= -1
        
        % Read in the file contents
        file = setstr(fread(fid)');
        fclose(fid);
                
        idx = min(findstr(file, '='));
        
        structname = deblank(file(9:idx-1));
        structname = fliplr(deblank(fliplr(structname)));

        % Remove the function prototype
        idx = findstr(file, char(10));
        if ~isempty(idx)
        	file(1:idx(1)) = [];
        end
        try
            laste = lasterr;
            eval(file);
            pluginStruct = eval(structname);
            
            % Remove unsupported plugins.
            supported = true;
            if isfield(pluginStruct,'supportedplatforms'),
                platform = computer;
                supported = find(strcmpi(platform,pluginStruct.supportedplatforms));
            end
            al = true;
            if isfield(pluginStruct, 'licenseavailable'),
                al = pluginStruct.licenseavailable;
            end
            if supported && al,
                plugins{end+1} = pluginStruct;
            end
            
        catch
            lasterr(laste);
            % NO OP, we do not want to warn, because we would get the same warning
            % for each object that tried to load the plug-in file
        end
    end
end

% [EOF]
