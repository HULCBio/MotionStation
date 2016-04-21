function w = javaSimulinkRoot

    persistent theRoot;

    if isempty(theRoot)
        theRoot = Simulink.Root;
    end

    w = java(theRoot);
    

%   Copyright 2002-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:32:15 $
