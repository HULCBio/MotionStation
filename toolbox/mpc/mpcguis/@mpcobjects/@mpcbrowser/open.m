function open(h)

% OPEN  Opens the mpcbrowser in the current state

% Author(s): Larry Ricker
% Revised:
% Copyright 1986-2003 The MathWorks, Inc.
% $Revision: 1.1.8.2 $ $Date: 2004/04/10 23:37:47 $

import com.mathworks.toolbox.mpc.*;
import com.mathworks.ide.workspace.*;

% refresh variable viewer
if ~isempty(h.filename) % file and pathname supplied
    if exist(h.filename) == 2
        xx = whos('-file',h.filename);
    else
        return
    end
else
    xx = evalin('base','whos');
end

% assemble variables structure
varStruc = []; 
ind = 1;
for k=1:length(xx)
    if isempty(h.typesallowed) || any(strcmpi(xx(k).class,h.typesallowed))
        entry = com.mathworks.mlwidgets.workspace.VariableIcon.getIcon(xx(k).name, xx(k).class);
        varStruc(ind).entry = entry;
        varStruc(ind).name = xx(k).name;
        varStruc(ind).size = xx(k).size;
        varStruc(ind).bytes = xx(k).bytes;
        varStruc(ind).class = xx(k).class;
        varStruc(ind).length = length(xx(k).size);
        ind = ind+1;
    end
end
% If a mpcbrowser exists update it, else create it    
if ~isempty(h.javahandle) & isjava(h.javahandle) 
    % abort if nothing has changed
    if ~isempty(varStruc) && ~isempty(h.variables) && isequal(varStruc.name,h.variables.name) && isequal(varStruc.size,h.variables.size) && ...
            isequal(varStruc.bytes,h.variables.bytes) && isequal(varStruc.class,h.variables.class)
        % cannot rely on the image having the same handle so we must
        % compare the other fields
        return
    end
    h.javahandle.removeAllItems; % we'll rebuild 
else
    h.javahandle = MPCimportView(h);
end   

% Reassemble the new mpcbrowser
for k=1:length(varStruc)
    h.javahandle.addItem(varStruc(k).entry, varStruc(k).size, varStruc(k).bytes, varStruc(k).class, varStruc(k).length);
end
h.variables = varStruc;

