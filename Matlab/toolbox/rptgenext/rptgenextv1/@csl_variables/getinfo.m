function out=getinfo(c)
%GETINFO returns a structure containing information about the component
%   I=GETINFO(C)
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
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:21:03 $

out=getprotocomp(c);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

out.Name = xlate('Model Variables');
out.Type = 'SL';
out.Desc = xlate('Shows all workspace variables used by a Simulink model.');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

out.att.isWorkspaceIO=logical(0);
out.att.TableTitle='Model Variables';

out.att.isBorder=logical(1);
out.att.isShowParentBlock=logical(1);
out.att.isShowCallingString=logical(1);
out.att.isShowVariableSize=logical(0);
out.att.isShowVariableMemory=logical(0);
out.att.isShowVariableClass=logical(0);
out.att.isShowVariableValue=logical(1);
out.att.isShowTunableProps=logical(0);

out.att.ParameterProps={};

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

out.attx.isWorkspaceIO.String=...
   'Include Workspace I/O parameters';
out.attx.TableTitle.String=...
   'Table title: ';
out.attx.TableTitle.isParsedText=1;

out.attx.isBorder.String=...
   'Display table border';
out.attx.isShowParentBlock.String=...
   'Parent block';
out.attx.isShowCallingString.String=...
   'Calling string';
out.attx.isShowVariableSize.String=...
   'Size of variable';
out.attx.isShowVariableMemory.String=...
   'Memory requirements';
out.attx.isShowVariableClass.String=...
   'Class of variable';
out.attx.isShowVariableValue.String=...
   'Value in workspace';
out.attx.isShowTunableProps.String=...
   'RTW storage class';

out.attx.ParameterProps.String=...
    'Data object parameters';
out.attx.ParameterProps.UIcontrol=...
    'multiedit';

