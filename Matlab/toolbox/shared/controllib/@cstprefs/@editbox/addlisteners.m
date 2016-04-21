function addlisteners(UnitBox)
% ADDLISTENERS  Installs generic listeners.

% Author: Kamesh Subbarao
%   $Revision: 1.1.6.2 $  $Date: 2004/04/11 00:15:36 $
%  Copyright 1986-2004 The MathWorks, Inc.
  
UnitBox.DataListener = ...
   handle.listener(UnitBox,findprop(UnitBox,'Data'),'PropertyPostSet',{@localReadProp UnitBox});

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% LocalReadProp 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function localReadProp(eventSrc,eventData,OptionsBox)
% Update the GUI Fields so that the GUI reflect the right values.
Target = OptionsBox.Target;
Target.updateProps(OptionsBox);
