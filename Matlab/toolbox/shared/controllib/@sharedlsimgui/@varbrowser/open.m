function changeFlag = open(h, varargin)

% OPEN  Opens the varbrowser in the current state for 2d variables

% Author(s): J. G. Owen
% Revised:
% Copyright 1986-2004 The MathWorks, Inc.
% $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:25:12 $

% Extra argument controls the size of variables seen

import com.mathworks.toolbox.control.spreadsheet.*;
import com.mathworks.ide.workspace.*;

changeFlag =true;

% refresh veriable viewer
if ~isempty(h.filename) % file and pathname supplied
    xx = whos('-file',h.filename);
else
    xx = evalin('base','whos');
end

if nargin>1
    numsizelimits = size(varargin{1},1);
else
    numsizelimits = 0;
end

% assemble variables structure
varStruc = []; 
ind = 1;
for k=1:length(xx)
    if (isempty(h.typesallowed) || any(strcmpi(xx(k).class,h.typesallowed))) && length(xx(k).size)<=2 && ...
            (numsizelimits==0 || any(all((ones(numsizelimits,1)*xx(k).size==varargin{1})' | isnan(varargin{1}))))
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

% If a varbrowser exists update it, else create it    
if ~isempty(h.javahandle) & isjava(h.javahandle) 
    % abort if nothing has changed
    if ~isempty(h.variables) && ~isempty(varStruc) && ...
        isequal(localGetField(varStruc,'name'), ...
            localGetField(h.variables,'name')) && ...     
        isequal(localGetField(varStruc,'size'),...
            localGetField(h.variables,'size')) && ...         
        isequal(localGetField(varStruc,'bytes'), ...
            localGetField(h.variables,'bytes')) && ...            
        isequal(localGetField(varStruc,'class'), ...
            localGetField(h.variables,'class'))
        % cannot rely on the image having the same handle so we must
        % compare the other fields
        changeFlag = false;
        return
    end
    h.javahandle.removeAllItems; % we'll rebuild 
else
    h.javahandle = ImportView(h);
end   

% Reassemble the new varbrowser
for k=1:length(varStruc)
    h.javahandle.addItem(varStruc(k).entry, varStruc(k).size, varStruc(k).bytes, varStruc(k).class, varStruc(k).length);
end
h.variables = varStruc;

function members = localGetField(strucarray,fieldname)

members = cell(length(strucarray),1);
for k=1:length(strucarray)
    members{k} = getfield(strucarray(k),fieldname);
end
    
