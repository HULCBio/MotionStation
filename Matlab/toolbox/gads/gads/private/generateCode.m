function code = generateCode( obj )
%GENERATECODE Generate m code to recreate a GA options object
%   generateCode(gaoptimset ) is a string that can be evaluated to produce
%   the options structure passed in.

%   Copyright 2004 The MathWorks, Inc.
%   $Revision: 1.3 $  $Date: 2004/01/16 16:49:59 $

% read the list of properties from another file.
% this list is shared between several m-files for consistency.
properties =  propertyList;

% make a default object. properties that match the values in the default
% will not be generated.
default = gaoptimset;

% first line
code = sprintf('options = gaoptimset;\n');

% for each property
for i = 1:length(properties)
    prop = properties{i};
    if(~isempty(prop)) % the property list has blank lines, ignore them
        value = obj.(prop);
        if(~isequal(value,default.(prop))) % don't generate code for defaults.
            code = [code sprintf('options.%s = %s;\n',prop,value2RHS(value))];
        end
    end
end
