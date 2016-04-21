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
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:22:13 $

out=getprotocomp(c);

out.Name = xlate('Object Name');
out.Type = 'SL';
out.Desc = ...
      xlate('Inserts the name of a  Model, System, Block, or Signal into the report.');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

out.att=struct('ObjectType','Automatic',...
   'isfullname',logical(0),...
   'renderAs','n');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

out.attx.ObjectType=struct(...
   'String','',...
   'enumValues',{{'Automatic' 'Model' 'System' 'Block' 'Signal'}},...
   'enumNames',{{'Automatic' '' '' '' ''}},...
   'UIcontrol','togglebutton');

out.attx.isfullname=struct(...
   'String','Show full path name');

out.attx.renderAs.String='';
out.attx.renderAs.enumValues={'n' 't n' 't-n' 't:n'};
out.attx.renderAs.enumNames={'Name' 'Type Name' 'Type - Name' 'Type: Name'};
out.attx.renderAs.UIcontrol='radiobutton';