function sbclose(fig)
%SBCLOSE Signal Browser close request function
%   This function is called when a browser window is closed.
%   SBCLOSE(FIG) closes the browser with figure handle FIG.
 
%   Copyright 1988-2002 The MathWorks, Inc.
% $Revision: 1.8 $

    if nargin<1
        fig = gcf;
    end

    ud = get(fig,'userdata');

    if ~isempty(ud.tabfig)
        delete(ud.tabfig)
    end
    
    delete(fig)

