function dspblkcopystw(blockh)

% Copyright 2004 The MathWorks, Inc.

block = getfullname(blockh);
obj = get_param(blockh,'object');

if str2num(block(end))+1

    %-- Get variable name
    vals = obj.MaskValues;
    idx = strmatch('VariableName',obj.MaskNames);
    varName = vals{idx};

    %--  Extract digit number from block name
    % double('0') = 48; double('9')=57;
    dBlock = double(block);
    h = and(dBlock>=48,dBlock<=57);
    if (max(find(h==0)) == length(h))
        hblock = [];
    else
        hBlock = block(max(find(h==0))+1:end);
    end

    %-- Extract digit number from variable name
    dVar = double(varName);
    h = and(dVar>=48,dVar<=57);
    if (max(find(h==0)) == length(h))
        hVar = varName;
    else
        hVar = varName(1:max(find(h==0)));
    end
    %-- Attach index
    vals{idx} = [hVar hBlock];

    %Restore mask Values settings
    obj.MaskValues = vals;

end
