function msgid = generatemsgid(id)
%GENERATEMSGID Returns the message ID.
%   GENERATEMSGID(ID) Returns the message id using ID as the mnemonic.  If
%   GENERATEMSGID is called from a method the class name will be included
%   in the message ID.  All packages will also be included if they exist.
%
%   Example:
%   % #1 In zerophase warn about the syntax change.
%   warning(generatemsgid('syntaxChanged'), ...
%       'The syntax of the zerophase function has changed.');
%   % The ID will be 'signal:zerophase:syntaxChanged'
%
%   % #2 In the SETANALYSIS method of FVTool error when an unrecognized
%   % analysis is specified.
%   error(generatemsgid('invalidAnalysis'), ...
%       '''%s'' is not a valid analysis.', out);
%   % The ID will be 'signal:siggui:fvtool:setanalysis:invalidAnalysis'

%   Author(s): J. Schickler
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.3.4.2 $  $Date: 2004/04/13 00:31:51 $

error(nargchk(1,1,nargin));

% Get the stack to determine the toolbox and the calling function.
s = dbstack('-completenames');

% If the stack is only 1 deep, this function was called from the command
% line.  This is not supported.
if length(s) == 1,
    error(generatemsgid('notCalledFromFunction'), ... 
        'GENERATEMSGID must be called from a function.');
end

% Get the toolbox from the path to the calling function by removing the
% matlabroot path and '\toolbox\' and strok'ing of the next filesep.
[t, rest] = strtok(s(2).file(length(matlabroot)+10:end), filesep);

% Get the filename from the left over path.
% Don't use fileparts for speed reasons.
findx = findstr(rest, filesep);

% The file name is between the last filesep and the '.'
f     = rest(max(findx)+1:findstr(rest, '.')-1);
rest(max(findx)+1:end) = [];

% If there is a '@' in the rest look for a package/class
obj = '';
i   = min(findstr(rest, '@'));

% Loop to find all @directories.  This will handle the current UDD directory
% structure and future nested packages.  It will also handle the old OOPS
% directory structure.
while ~isempty(i)
    
    % Remove the unnecessary path before the '@'
    rest = rest(i+1:end);
    
    % The package/class name runs up to the next filesep.
    findx = findstr(rest, filesep);
    obj = sprintf('%s%s:', obj, rest(1:min(findx)-1));
    
    % Find the next @ directory
    i = min(findstr(rest, '@'));
end

% Combine all the strings.
msgid = sprintf('%s:%s%s:%s', t, obj, f, id);

% [EOF]
