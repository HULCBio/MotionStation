function out = comempty(vaa, handle, default);
%COMEMPTY Error message for empty entries in COMMGUI.
%
%WARNING: This is an obsolete function and may be removed in the future.

% Copyright 1996-2002 The MathWorks, Inc.
% $Revision: 1.12 $

if isempty(vaa)
    out = default;
    if isstr(out)
        set(handle,'String',out,'ForegroundColor',[1 0 0])
    else
        set(handle,'String',mat2str(out),'ForegroundColor',[1 0 0])
    end;
else
    out = vaa;
end;
