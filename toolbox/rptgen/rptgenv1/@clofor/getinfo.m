function out=getinfo(c)
%GETINFO returns a structure containing information about the component
%   I=GETINFO(CFRIMAGE)
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
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:15:02 $

out=getprotocomp(c);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

out.Name = xlate('For Loop');
out.Type = 'LO';
out.Desc = xlate('Loops over a workspace variable.');
out.ValidChildren={logical(1)};

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

out.att=struct(...
   'LoopType','$increment',...
   'LoopVector','1 2 3 4 5',...
   'StartNumber','1',...
   'IncrementNumber','1',...
   'EndNumber','5',...
   'isUseVariable',logical(1),...
   'VariableName','RPTGEN_LOOP',...
   'isCleanup',logical(1));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

out.attx.LoopType.String='';
out.attx.LoopType.enumValues={'$increment','$vector'};
out.attx.LoopType.enumNames={
   'Incremented indices'
   'Vector of indices'
};
out.attx.LoopType.UIcontrol='radiobutton';

out.attx.LoopVector.String = '     Vector ';
out.attx.LoopVector.Type   = 'STRING';


out.attx.StartNumber=struct('String','Start ',...
   'Type','STRING');

out.attx.IncrementNumber=struct('String','Increment ',...
   'Type','STRING');

out.attx.EndNumber=struct('String','End ',...
   'Type','STRING');

out.attx.isCleanup.String=...
   'Remove variable from workspace when done ';

out.attx.VariableName.String='Variable name ';

out.attx.isUseVariable.String=...
   'Show index value in base workspace';