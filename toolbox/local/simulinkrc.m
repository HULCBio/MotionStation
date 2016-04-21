function simulinkrc
%SIMULINKRC Master startup M-file for Simulink
%   SIMULINKRC is automatically executed by Simulink during startup.
%
%       On multi-user or networked systems, the system manager can put
%       any messages, definitions, etc. that apply to all users here.
%
%   SIMULINKRC also invokes a STARTUPSL command if the file 'startupsl.m'
%   exists on the MATLAB path.

%   Copyright 1984-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2004/04/30 02:54:02 $

%% Use the default paper set up by HG .. see hgrc.m for more details
defaultpaper = get(0,'DefaultFigurePaperType');
defaultunits = get(0,'DefaultFigurePaperUnits');

% Simulink defaults
set_param(0,'PaperType',defaultpaper);
set_param(0,'PaperUnits',defaultunits);

% Load preference setting of Simulink configuration set
try
  cs = getActiveConfigSet(0);
  cs.savePreferences('Load');
end

% Execute startup M-file, if it exists.
if (exist('startupsl','file') == 2) ||...
   (exist('startupsl','file') == 6)
  evalin('base','startupsl')
end

