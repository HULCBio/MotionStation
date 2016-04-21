function newfun(filename,description)
%NEWFUN  Create a new function given the filename and description
%   NEWFUN(FILENAME, DESCRIPTION)

% Copyright 1984-2003 The MathWorks, Inc.

if nargin < 1
    filename = '';
end

if nargin <2 
    description = '';
end

str = mfiletemplate('full',filename,description);

if nargout == 0
    % put the code into a new Editor buffer
    com.mathworks.mlservices.MLEditorServices.newDocument(str)
end
