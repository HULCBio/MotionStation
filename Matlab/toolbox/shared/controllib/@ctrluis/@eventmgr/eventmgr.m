function h = eventmgr(Container)
% Returns instance of @eventmgr class

%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:17:50 $

h = ctrluis.eventmgr;
if nargin
    h.SelectedContainer = Container;
end
