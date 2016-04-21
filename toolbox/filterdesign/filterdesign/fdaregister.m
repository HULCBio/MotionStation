function s = fdaregister
%FDAREGISTER Registers the Filter Design plugin with Filter Design & Analysis Tool (FDATool).

%   Author(s): J. Schickler
%   Copyright 1999-2003 The MathWorks, Inc.
%   $Revision: 1.4.4.3 $  $Date: 2004/04/12 23:25:22 $

s.plugin           = {@fdplugin};
s.name             = {'Filter Design Toolbox'};
s.version          = {1.0};
s.licenseavailable = license('test', 'Filter_Design_Toolbox');

% [EOF]
