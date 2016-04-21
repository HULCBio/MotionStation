function diff2asv(filename)
%DIFF2ASV  Compare file to autosaved version if it exists
%   DIFF2ASV(filename)
%
%   See also VISDIFF, DIFFRPT.

% Copyright 1984-2003 The MathWorks, Inc.

fullfilename = which(filename);
[pt,fn,xt] = fileparts(fullfilename);

asvFilename = com.mathworks.mde.editor.EditorOptions.getAutoSaveFilename( ...
    pt,[fn xt]);

asvFilename = char(asvFilename);

if isempty(asvFilename)
    disp('Autosave is not enabled')
else
    asvPath = fileparts(asvFilename);
end

d = dir(asvFilename);
if ~isempty(d)
    visdiff(asvFilename,fullfilename)
else
    disp(['File ' fn ' is not in autosave directory ' asvPath])
end
