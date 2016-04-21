function out = openmat(filename)
%OPENMAT   Load data from file and show preview.
%   Helper function for OPEN.
%
%   See OPEN.

%   Copyright 1984-2002 The MathWorks, Inc.
%   $Revision: 1.11 $  $Date: 2002/04/10 17:05:16 $

try
   out = load(filename); 
catch
    % we only want the message from lasterr, not the stack trace
    le = lasterr;
    euIndex = findstr(le, sprintf('Error using ==>'));
    if ~isempty(euIndex)
        le = le(euIndex(end):end);
        nlIndex = findstr(le,sprintf('\n'));
        if ~isempty(nlIndex)
            le = le(nlIndex(1) + 1 : end);
            while ~isempty(le) & length(le) > 1 & strcmp(le(end), sprintf('\n'))
                le = le(1:end - 1);
            end
        end
    end
    error(le)
end
    
