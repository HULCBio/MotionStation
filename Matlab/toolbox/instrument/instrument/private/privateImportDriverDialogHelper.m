function out = privateImportDriverDialogHelper
%PRIVATEIMPORTDRIVERDIALOGHELPER helper function for MIDEDIT import dialog.
%
%   PRIVATEIMPORTDRIVERDIALOGHELPER helper function used by the MATLAB 
%   Instrument Driver Editor (MIDEDIT) to:
%      1. Find the available VXIplug&play drivers
%      2. Find the available IVI logical names.
%
%   This function should not be called directly by the user.
%  
 
%   MP 11-04-03
%   Copyright 1999-2004 The MathWorks, Inc. 
%   $Revision: 1.1.6.2 $  $Date: 2004/01/16 20:02:46 $

vxipnp = instrhwinfo('vxipnp');
ivi    = instrhwinfo('ivi');

out = {vxipnp.InstalledDrivers, ivi.LogicalNames, ivi.ProgramIDs, ivi.Modules, privateGetVXIPNPPath, ivi.IVIRootPath};
