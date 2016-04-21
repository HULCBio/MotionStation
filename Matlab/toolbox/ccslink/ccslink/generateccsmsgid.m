function msgid = generateccsmsgid(id)
%GENERATECCSMSGID Returns the message ID.
%   GENERATECCSMSGID(ID) Returns the message id using ID as the mnemonic. 

%   Copyright 2003-2004 The MathWorks, Inc.

error(nargchk(1,1,nargin));

% Get the stack to determine the toolbofx and the calling function.
s = dbstack('-completenames');

% If the stack is only 1 deep, this function was called from the command
% line.  This is not supported.
if length(s) == 1,
    error(generateccsmsgid('notCalledFromFunction'), ... 
        'GENERATECCSMSGID must be called from a function.');
end

% Get the class or subfolder the error was generated.
isaclass = strfind(s(2).file,'@ccs\@');
filesepidx = strfind(s(2).file,'\');
if isaclass
    % Assumes that you are at a class directory toolbox\ccslink\ccslink\@ccs\@...
    secondParam = upper(s(2).file(isaclass+6:filesepidx(end)-1));
elseif strfind(s(2).file,'@ccs')
    % Assumes that you are at the directory toolbox\ccslink\ccslink\@ccs
    secondParam = 'CCS';
else 
    % Assumes that you are at the directory toolbox\ccslink\ccslink,
    % toolbox\ccslink\ccsdemos or a subdirectory 
    secondParam = upper(s(2).file(length(matlabroot)+18:filesepidx(end)-1));
end
secondParam = strrep(secondParam,'\',':');

% Combine all the strings.
msgid = sprintf('MATLAB:%s:%s', secondParam, id);

% [EOF] generateccsmsgid.m
