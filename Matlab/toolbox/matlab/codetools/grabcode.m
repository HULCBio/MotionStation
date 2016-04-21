function codeStrOut = grabcode(filename)
%GRABCODE  Pull M-code from MATLAB-generated HTML demo files.
%   codeStrOut = GRABCODE(filename) or 
%   codeStrOut = GRABCODE(url)
%
%   See also PUBLISH.

%   Copyright 1984-2004 The MathWorks, Inc.

% Auto-detect if this is a URL by looking for :// pattern
if strfind(filename,'://')
    % filename is a URL
    fileStr = urlread(filename);
else 
    % filename is a file
    fileStr = file2char(filename);
end

matches = regexp(fileStr,'##### SOURCE BEGIN #####\n(.*)\n##### SOURCE END #####','tokens','once');
codeStr = matches{1};
codeStr = strrep(codeStr,'REPLACE_WITH_DASH_DASH','--');

if nargout == 0
    com.mathworks.mlservices.MLEditorServices.newDocument(codeStr);
else
    codeStrOut = codeStr;
end
