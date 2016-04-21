function h = ModelExplorer(rt)
    % ModelExplorer Class constructor function
    % Wraps calls to the java ModelExplorer


    % Instantiate object
    h = DAStudio.ModelExplorer;
    connect(DAStudio.Root,h,'down');

    if nargin == 0
        root = slroot;
    else
        root = rt;
    end

    h.jModelExplorer = handle(com.mathworks.toolbox.dastudio.explorer.ModelExplorer(java(root)));


%   Copyright 2002-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:31:00 $
