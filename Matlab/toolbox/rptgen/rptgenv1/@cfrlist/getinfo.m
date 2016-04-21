function out=getinfo(c)
%GETINFO returns a structure containing information about the component
%   I=GETINFO(CFRLIST)
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
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:13:35 $

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

out=getprotocomp(c);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


out.Name = xlate('List');
out.Type = 'FR';
out.Desc = xlate('Inserts a bulleted or numbered list into the report.');
out.ValidChildren={logical(1)};

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


out.att.ListTitle='';
out.att.isSourceFromWorkspace=logical(0);
out.att.SourceVariableName='';
out.att.SourceCell={};
out.att.ListStyle='ItemizedList';
out.att.Spacing='Normal';
out.att.NumerationType='Arabic';
out.att.NumInherit='Ignore';
out.att.NumContinue='Restarts';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


out.attx.SourceVariableName.String=...
   'Create list from cell array with workspace variable name:';

out.attx.ListTitle.String='List title';
out.attx.ListTitle.isParsedText=logical(1);

out.attx.ListStyle=struct(...
   'String','List style',...
   'enumValues',{{'ItemizedList' 
      'OrderedList'}},...
   'enumNames',{{'Bulleted list'
      'Numbered list'}});

out.attx.Spacing.enumValues={'Compact'
   'Normal'};

out.attx.NumerationType=struct(...
   'String','Numbering style',...
   'enumValues',{{'Arabic' 
      'Loweralpha' 
      'Upperalpha' 
      'Lowerroman' 
      'Upperroman'}},...
   'enumNames',{{'1,2,3,4,...'
      'a,b,c,d,...'
      'A,B,C,D,...'
      'i,ii,iii,iv,...'
      'I,II,III,IV,...'}});

out.attx.NumInherit=struct(...
   'String','',...
   'enumValues',{{'Inherit'
      'Ignore'}},...
   'enumNames',{{'Show parent number in nested list (1.1.a)'
      'Show only current list value (a)'}},...
   'UIcontrol','radiobutton');

out.attx.NumContinue=struct(...
   'String','',...
   'enumValues',{{'Continues'
      'Restarts'}},...
   'enumNames',{{'Continue numbering from previous list'
      'Always start at 1'}},...
   'UIcontrol','radiobutton');

