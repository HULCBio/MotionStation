function inspect(obj)
%INSPECT Open the inspector and inspect timer object properties.

%    RDD 11-20-2001
%    Copyright 2001-2003 The MathWorks, Inc.
%    $Revision: 1.1.6.2 $  $Date: 2004/03/30 13:07:24 $

% Error checking.
if length(obj) ~= 1
    error('MATLAB:timer:singletonrequired',timererror('MATLAB:timer:singletonrequired'));
end

if ~isvalid(obj)
   error('MATLAB:timer:invalid',timererror('MATLAB:timer:invalid'));
end

inspect(obj.jobject);
% Open the inspector.
