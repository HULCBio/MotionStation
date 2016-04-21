function slsaveas(mdlR14, mdlOld, saveAsVersion, isSimulink)
%SLSAVEAS converts a Simulink 6.0 (R14) model into a Simulink 5.1 (R13SP1) model.
%
%   WARNING: This function is being deprecated in R14. It will be removed in 
%   a future version of Simulink. Please use save_system instead.
%
%   SLSAVEAS('SYS') converts a Simulink 6 (R14) model to be loaded in
%   Simulink 5.1 (R13SP1). It creates a model called 'SYS_r13sp1' in the
%   current directory. 
%
%   SLSAVEAS takes an optional second argument for the name of the 
%   R13 model file:
%
%   SLSAVEAS('SYS', 'SYS2')
%
%   SLSAVEAS('SYS', 'SYS2','SaveAsR13SP1')
%   Converts the model into Simulink R13 5.1 (R13SP1) format
%
%   SLSAVEAS('SYS', 'SYS2','SaveAsR13')
%   Converts the model into Simulink R13 5.0 format
%  
%   SLSAVEAS('SYS', 'SYS2','SaveAsR12PointOne')
%   Converts the model into Simulink R12 4.1 (R12.1) format
%
%   SLSAVEAS('SYS', 'SYS2','SaveAsR12')
%   Converts the model into Simulink R12 4.0 (R12) format
%
%   The above commands convert R14-only Simulink blocks into empty 
%   masked subsystem blocks colored yellow.    
%
%   Note: although this command converts a model that contains R14-only
%   features and/or blocks, the converted model is likely to produce
%   incorrect results.
%   
%   See also SAVE_SYSTEM
  
%   Copyright 1990-2004 The MathWorks, Inc.
%
%   $Revision: 1.12.4.4 $
%   Ricardo Monteiro  10/23/2000
  
  error(nargchk(1, 4, nargin));
  
  %
  % The fourth parameter isSimulink is not used.
  %
  
  if nargin < 2
    mdlOld = [mdlR14 '_r13sp1.mdl'];
    saveAsVersion = 'SaveAsR13SP1';
  end
  
  if nargin < 3
    saveAsVersion = 'SaveAsR13SP1';
  elseif (nargin == 3)
    saveAsVersion = lower(saveAsVersion);
  else
    saveAsVersion = lower(saveAsVersion);
  end
  
  %if the second argument is an empty string create sys_r13sp1
  if strcmp(mdlOld, '')
    if strcmp(saveAsVersion, 'saveasr12')
      mdlOld = [mdlR14 '_r12.mdl'];
    elseif strcmp(saveAsVersion, 'saveasr12pointone')
      mdlOld = [mdlR14 '_r12p1.mdl'];
    else
      mdlOld = [mdlR14 '_r13sp1.mdl'];
    end
  end
  
  % Sanity checks
  mdlR14FullPath = which(mdlR14);
  mdlOldWithExt = addExtension(mdlOld);
  
  if (exist(mdlR14FullPath) ~= 4)
    error(['Unable to find the model file named ' mdlR14])
    return;
  end
  
  if (strcmp(getModelName(mdlR14FullPath), getModelName(mdlOldWithExt)))
    error(' Cannot save model with same names')
    return;
  end
  
  % Call save_system
  version = '';
  switch saveAsVersion
   case 'saveasr13sp1'
    version = 'R13SP1';
   case 'saveasr13'
    version = 'R13';
   case 'saveasr12pointone'
    version = 'R12P1';
   case 'saveasr12'
    version = 'R12';
   otherwise
    error('Unkown saveas version in slsaveas.m');
  end
  
  try
    save_system(mdlR14, mdlOld, '', version);
  catch
    disp(lasterr);
  end
  
% Function: getModelName =======================================================
% Abstract: 
%      Returns the model without the path. It will still have the .mdl extension.       
%
function mdl = getModelName(name)
  hasfilesep = findstr(name,filesep);
  if(~isempty(hasfilesep))
    fns = findstr(name,filesep);
    mdl= name(fns(end)+1:end);
  else
    mdl = name;
  end
  
% Function: addExtension =======================================================
% Abstract: 
%      Adds the .mdl extension to the model if needed.
%
function mdl = addExtension(name)
  hasextension = findstr(name,'.');
  if(isempty(hasextension))
    mdl = [name '.mdl'];
  else
    mdl = name;
  end