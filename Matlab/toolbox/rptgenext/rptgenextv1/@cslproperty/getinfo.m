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
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:21:31 $

out=getprotocomp(c);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

out.Name = xlate('Object Property');
out.Type = 'SL';
out.Desc = ...
      xlate('Inserts a single property for a  Model, System, Block, or Signal into the report.');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

out.att.ObjectType='System';

out.att.ModelProperty='Name';
out.att.SystemProperty='Name';
out.att.BlockProperty='Name';
out.att.SignalProperty='Name';

out.att.Render=3;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

out.attx.ObjectType=struct('String','',...
   'enumValues',{{'Model' 'System' 'Block' 'Signal'}},...
   'enumNames',{{'' '' '' ''}},...
   'UIcontrol','togglebutton');

out.attx.Render.String='';
out.attx.Render.enumValues={1 2 3};
out.attx.Render.enumNames={'Value'
   'Property: Value'
   'PROPERTY Value'};
out.attx.Render.UIcontrol='radiobutton';
