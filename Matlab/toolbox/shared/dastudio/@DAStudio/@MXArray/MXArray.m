function h = MXArray(nm, ws)
    % MXArray  Class constructor function

    % Instantiate object
    h = DAStudio.MXArray;

    if nargin == 0
        error('Name must be specified');
    elseif nargin == 1
        h.workspace = DAStudio.WorkspaceWrapper;
    else
        h.workspace = ws;
    end

    h.name = nm;


%   Copyright 2002-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:30:56 $
