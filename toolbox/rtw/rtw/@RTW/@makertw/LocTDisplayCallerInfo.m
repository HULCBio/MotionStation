function callerName = LocTDisplayCallerInfo(h, headerStr)
% Check the m-file's caller's name
%   Note: It's not recommended to be overloaded in subclass.

%   Copyright 2002 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2002/09/23 16:27:16 $

[dbStackInfo,dbLineInfo] = dbstack;
if(length(dbStackInfo)>2)
    callerName = strip_name(dbStackInfo(3).name);
else
    callerName = ''; %make_rtw invoked from cmd line
end

function name = strip_name(name)

idx = find(name==filesep);
if(~isempty(idx))
    name = name(max(idx)+1:end);
end