function out=getinfo(c)
%GETINFO returns a structure containing information about the component
%   I=GETINFO(CSL_MDL_LOOP)
%
%   I.Name - component informal name
%   I.Type - component general category 2-letter code
%   I.Desc - short description of the component
%   I.ValidChildren - shows whether or not component can have children
%          ValidChildren={logical(0)} for no children
%          ValidChildren={logical(1)} if children are allowed
%   I.att - component attributes
%   I.attx - information about component attributes
%   I.ref - reference structure
%   I.x - temporary attribute page handle structure

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:20:07 $

out=getprotocomp(c);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

out.Name = xlate('Model Loop');
out.Type = 'SL';
out.Desc = xlate('Includes specified models and systems in report');
out.ValidChildren={logical(1)};

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

out.att.LoopType='Current';

out.att.CurrentModels=struct('isActive',logical(1),...
   'MdlName','$current',...
   'MdlCurrSys',{{'$current'}},...
   'SysLoopType','$all',...
   'isMask','graphical',...
   'isLibrary','off');

out.att.AllModels=struct('isActive',logical(1),...
   'MdlName','$all',...
   'MdlCurrSys',{{'$top'}},...
   'SysLoopType','$all',...
   'isMask','graphical',...
   'isLibrary','off');

out.att.CustomModels=struct('isActive',logical(1),...
   'MdlName','',...
   'MdlCurrSys',{{'$top'}},...
   'SysLoopType','$all',...
   'isMask','graphical',...
   'isLibrary','off');

out.attx.LoopType.String='';
out.attx.LoopType.enumValues={'Current','All','Custom'};
out.attx.LoopType.enumNames={
   'Current model'
   'All visible models'
   'Custom list of models'
};
out.attx.LoopType.UIcontrol='radiobutton';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Valid isActive values:
% logical(1)/logical(0)
% 
% note: isActive won't be used for this release.  We'll just
% assume that all models on the list are active.

%Valid MdlName values:
% $current - for current model
% $all - for all models
% string - model name (may be full path name)

%Valid MdlCurrSys values (cell array - may be more than one)
% $current - current system
% $top - top-level system
% string - system name (must be full path name)

%Valid SysLoopType values
% $all - all systems in model
% $current - systems defined in MdlCurrSys
% $currentAbove - systems in MdlCurrSys + parents
% $currentBelow - systems in MdlCurrSys + children

%Valid isMask values
% 'none'
% 'graphical'
% 'functional'
% 'all'

%Valid isLibrary values
% 'off'
% 'on'
% 'unique'