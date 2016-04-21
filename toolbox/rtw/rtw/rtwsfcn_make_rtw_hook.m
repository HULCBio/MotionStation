function rtwsfcn_make_rtw_hook(varargin)
% RTWSFCN_MAKE_RTW_HOOK - rtwsfcn target-specific hook file for the build process 
%   (make_rtw).

%   Copyright 1994-2002 The MathWorks, Inc.
%   $Revision: 1.3 $ $Date: 2002/04/10 17:55:05 $

persistent MODEL_SETTINGS

Action    = varargin{1};
modelName = varargin{2};
buildArgs = varargin{6};

switch Action
 case 'entry'
  % set the target type
  set_param(modelName, 'TargetStyle', 'SimulationTarget');
end
