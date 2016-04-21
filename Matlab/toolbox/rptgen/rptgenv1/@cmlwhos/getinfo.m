function out=getinfo(c)
%GETINFO returns a structure containing information about the component
%   I=GETINFO(CMLWHOS)
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
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:15:45 $

out=getprotocomp(c);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

out.Name = xlate('Variable Table');
out.Type = 'ML';
out.Desc = xlate('Lists all variables with information about size, bytes, and class.');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

out.att.Source='WORKSPACE';
out.att.Filename='';
out.att.TitleType='auto';
out.att.TableTitle='Variables';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

out.att.isSize=logical(1);
out.att.isBytes=logical(1);
out.att.isClass=logical(1);
out.att.isValue=logical(0);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

out.attx.Filename.String='';
out.attx.Filename.UIcontrol='filebrowse';
out.attx.Filename.Ext='mat';
out.attx.Filename.isParsedText=logical(1);

out.attx.Source=struct('String','Read variables from:',...
   'enumValues',{{'WORKSPACE' 'MATFILE'}},...
   'enumNames',{{'Base workspace' 'MAT-file: '}},...
   'UIcontrol','radiobutton');

out.attx.TitleType.String='Table title ';
out.attx.TitleType.enumValues={'auto' 'manual'};
out.attx.TitleType.enumNames={'Automatic' 'Manual '};
out.attx.TitleType.UIcontrol='radiobutton';

out.attx.TableTitle.String='';
out.attx.TableTitle.isParsedText=logical(1);


out.attx.isSize.String='Variable size (MxN)';
out.attx.isBytes.String='Variable memory bytes';
out.attx.isClass.String='Variable class';
out.attx.isValue.String='Variable value';