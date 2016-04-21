function out=getinfo(c)
%GETINFO returns a structure containing information about the component
%   I=GETINFO(CFRPARAGRAPH)
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
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:13:42 $

out=getprotocomp(c);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%5

out.Name = xlate('Paragraph');
out.Type = 'FR';
out.Desc = xlate('Inserts a paragraph into the report.');
out.ValidChildren={logical(1)};

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

out.att.TitleType='none';
out.att.ParaTitle=xlate('Paragraph Title');

out.att.ParaText={''};

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

out.attx.TitleType.String='';
out.attx.TitleType.enumValues={
   'none'
   'subcomp'
   'specify'
};
out.attx.TitleType.enumNames={
   'No paragraph title'
   'Get title from first subcomponent'
   'Specify title: '
};
out.attx.TitleType.UIcontrol='radiobutton';

out.attx.ParaTitle.String='';
out.attx.ParaTitle.isParsedText=logical(1);

out.attx.ParaText=struct('String','',...
   'UIcontrol','multiedit',...
   'isParsedText',logical(1));

