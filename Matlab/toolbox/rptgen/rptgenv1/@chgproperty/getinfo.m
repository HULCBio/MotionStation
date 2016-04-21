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
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:14:33 $

out=getprotocomp(c);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

out.Name = xlate('Handle Graphics Parameter');
out.Type = 'HG';
out.Desc = xlate('Inserts a single system property and value into the report.');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

out.att.ObjectType='Figure';

out.att.FigureProperty='Name';
out.att.AxesProperty='Title';
out.att.ObjectProperty='Tag';

out.att.Render=3;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

out.attx.ObjectType.String='';
out.attx.ObjectType.enumValues={'Figure' 'Axes' 'Object'};
out.attx.ObjectType.enumNames={'' '' ''};
out.attx.ObjectType.UIcontrol='togglebutton';

out.attx.Render.String='';
out.attx.Render.enumValues={1 2 3};
out.attx.Render.enumNames={'Value'
   'Property: Value'
   'PROPERTY Value'};
out.attx.Render.UIcontrol='radiobutton';
