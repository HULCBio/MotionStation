function out=getinfo(c)
%GETINFO returns a structure containing information about the component

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:14:26 $


out=getprotocomp(c);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

out.Name = xlate('Graphics Object Name');
out.Type = 'HG';
out.Desc = xlate('Inserts the name of an HG object into the report.');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

out.att.ObjType='Figure';
out.att.renderAs='n';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

out.attx.ObjType.String='';
out.attx.ObjType.UIcontrol='togglebutton';
out.attx.ObjType.enumValues={'Figure' 'Axes' 'Object'};
out.attx.ObjType.enumNames={'Figure'
   'Axes'
   'Other object'};

out.attx.renderAs.String='';
out.attx.renderAs.enumValues={'n' 't n' 't-n' 't:n'};
out.attx.renderAs.enumNames={'Name' 'Type Name' 'Type - Name' 'Type: Name'};
out.attx.renderAs.UIcontrol='radiobutton';
