function htmlOut = visdir(dirname)
%VISDIR  Directory reporting HTML gateway function.
%   VISDIR(dirname) calls VISDIR on the specified directory dirname.
%   VISDIR is called by the Current Directory Browser interface and is not
%   intended as a user-callable function.

% Copyright 1984-2004 The MathWorks, Inc.

if nargin<1
    dirname = cd;
end

try
    htmlOut = standardrpt(dirname);
catch
    htmlOut = '';
    errMsg = lasterror;
end

if isempty(htmlOut)
    % If output of one of the files fails, catch the problem here
    s{1} = makeheadhtml;
    s{end+1} = '<title>Visual Directory</title>';
    s{end+1} = '</head>';   

    s{end+1} = '<body>';
    s{end+1} = sprintf('<pre style="color:#F00">%s<br/>%s</pre>', ...
        errMsg.identifier, errMsg.message);

    htmlOut = [s{:}];
end