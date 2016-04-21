function nlinopt(Model)
%NLINOPT  Obsolete NCD command for running the optimization algorithm.
%
%   NLINOPT(MODEL) starts a response optimization for the Simulink
%   model with name MODEL.  A valid ncdStruct variable must exist
%   in the wortkspace.
%
%   See also SROPROJECT, OPTIMIZE.

%   Author(s): A. Potvin, 12-1-92
%              M. Yeddanapudi, Sept. 24, '96
%   Copyright 1990-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $ $Date: 2004/04/11 00:46:59 $

% RE: Assumes old NCD blocks have already been upgraded

% Is there a valid ncdStruct variable in the workspace?
try 
   ncdStruct = evalin('base','ncdStruct');
catch
   error('There is no ncdStruct variable in the workspace.')
end

% Is the model open?
LoadFlag = isempty(find(get_param(0,'Object'),'Name',Model));
if LoadFlag
   try
      load_system(Model)
   catch
      rethrow(lasterror)
   end
end

% Look for NCD blocks
NCDBlocks = find_system(Model,'MaskType','NCD Outport');
if ~isempty(NCDBlocks)
   error('You must first upgrade old NCD blocks with NCDUPDATE.')
end

% Load optimization settings
if isa(ncdStruct,'struct')
   % Construct new project for Simulink model
   Proj = srogui.SimProjectForm;
   Proj.Name = Model;
   % Initialize project with one constraint per block in MODEL
   Proj.init(Model)
   % Read data from NCD struct
   Proj.loadNCDStruct(ncdStruct)
elseif isa(ncdStruct,'srogui.SimProjectForm')
   % Data already reformatted 
   Proj = ncdStruct;
else
   error('Variable ncdStruct does not contain valid settings.')
end

% Evaluate form
RunProj = evalForm(Proj);

% Start optimization
try
   optimize(RunProj)
catch
   rethrow(lasterror)
end

% Clean up
if LoadFlag
   close_system(Model,0);
end
