function [x,y,colheadings,timeunits] = setposition(h,pos,name)
%SETPOSITION
%
% Author(s): James G. Owen
% Revised:
% Copyright 1986-2003 The MathWorks, Inc.
% $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:32:59 $

% Used by java to keep @preprocess in synch with dataset combo


% If the position has changed:
% i) the column must be reset to 1
% ii) the editor window closed as the size of the data vector may have
% changed

if h.Position ~= pos
    h.Column = 1;
    h.Position = pos;
    if ~isempty(h.Window) && ishandle(h.Window)
       delete(h.Window);
       h.Window = [];
    end
end

[x,y,colheadings,timeunits] = getdata(h,name);
