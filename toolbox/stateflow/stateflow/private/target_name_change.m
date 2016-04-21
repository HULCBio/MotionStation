function target_name_change(target),

%   Copyright 1995-2002 The MathWorks, Inc.
%   $Revision: 1.2.2.1 $  $Date: 2004/04/15 01:00:57 $

targetName = sf('get',target,'target.name');

targetFile = find_target_files(targetName);
if ~isempty(targetFile)
    sf('set',target,'target.targetFunction',targetFile.fcn);
end

target_methods('namechange',target);
