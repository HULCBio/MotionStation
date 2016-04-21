function out=getinfo(c)
%GETINFO returns a structure containing information about the component
%   I=GETINFO(CMLVARIABLE)
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
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:15:38 $

out=getprotocomp(c);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

out.Name = xlate('Insert Variable');
out.Type = 'ML';
out.Desc = xlate('Inserts a variable from the workspace or a MAT-file into the report.');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

out.att.source='W';
out.att.filename='';
out.att.variable='';
out.att.sizeLimit=32;
out.att.forceinline=logical(0);
out.att.renderAs='v';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

out.attx.source=struct('String','Variable location ',...
   'enumValues',{{'W' 'M' 'G'}},...
   'enumNames',{{'Workspace'
      'MAT-File'
      'Global variable'}},...
   'UIcontrol','radiobutton');

out.attx.filename.String='';
out.attx.filename.Ext='mat';
out.attx.filename.isParsedText=logical(1);

out.attx.variable.String='Variable name ';
out.attx.variable.isParsedText=logical(1);


out.attx.sizeLimit.String='';
out.attx.sizeLimit.enumValues={0 32};
out.attx.sizeLimit.enumNames={'Show entire array'
   'Show large arrays as "[MxN CLASS]"'};
out.attx.sizeLimit.UIcontrol='popupmenu';

out.attx.forceinline.String='';
out.attx.forceinline.enumValues={logical(1) logical(0)};
out.attx.forceinline.enumNames={...
      'Render variable as single-line text only'
   'Render 1xN structures and non-character arrays as tables'};
out.attx.forceinline.UIcontrol='popupmenu';

out.attx.renderAs.String='Name display ';
out.attx.renderAs.enumValues={'v' 'p: v' 'Pv'};
out.attx.renderAs.enumNames={'Value' 'Name: Value' 'NAME Value'};
out.attx.renderAs.UIcontrol='radiobutton';