function fdapluginstruct = fdaregister
%FDAREGISTER Registers plug-ins with Filter Design & Analysis Tool (FDATool).

%   Copyright 1995-2003 The MathWorks, Inc.
%   $Revision: 1.2.4.4 $  $Date: 2004/04/12 23:05:22 $

fdapluginstruct.plugin           = {@dspplugin};
fdapluginstruct.name             = {'Signal Processing Blockset'};
fdapluginstruct.version          = {1.0};
fdapluginstruct.licenseavailable = license('test', 'Signal_Blocks');

% [EOF]
