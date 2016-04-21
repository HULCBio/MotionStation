function privateCleanup(tag)
%PRIVATECLEANUP Cleanup before closing softscope.
%
%   PRIVATECLEANUP cleans up before softscope is closed.
%
%   This function should not be used directly by users.
%
%   See also SOFTSCOPE.
%

%   MP 1-03-02
%   Copyright 1998-2003 The MathWorks, Inc. 
%   $Revision: 1.1.2.3 $  $Date: 2003/08/29 04:45:28 $

if isempty(tag)
    return;
end

frame = findobj('Tag', tag);

if isempty(frame)
    return;
end

data = get(frame, 'UserData');
if ~data.created & ~isempty(data.analoginput)
    delete(data.analoginput);
end

delete(frame);