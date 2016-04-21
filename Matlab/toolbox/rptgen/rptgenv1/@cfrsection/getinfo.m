function out=getinfo(c)
%GETINFO returns a structure containing information about the component
%   I=GETINFO(CFRSECTION)
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
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:13:49 $

out=getprotocomp(c);

out.Name = xlate('Chapter/Subsection');
out.Type = 'FR';
out.Desc = xlate('Groups portions of the report into sections');
out.ValidChildren={logical(1)};

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

out.att.SectionTitle=xlate('Section Title');
out.att.isTitleFromSubComponent=logical(0);
out.att.NumberMode = 'auto';
out.att.Number = '1';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

out.attx.SectionTitle.String='';
out.attx.SectionTitle.isParsedText=logical(1);
out.attx.isTitleFromSubComponent=struct(...
   'String','',...
   'enumValues',{{logical(1) logical(0)}},...
   'enumNames',{{'Get title from first subcomponent',...
         'Custom title: '}},...
   'UIcontrol','radiobutton');
out.attx.NumberMode=struct(...
   'String','',...
   'enumValues',{{'auto','manual'}},...
   'enumNames',{{'Automatically increment section numbers',...
         'Custom number: '}},...
   'UIcontrol','radiobutton');
out.attx.Number.String = '';
out.attx.Number.isParsedText = true;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

out.ref.allTypes={
   'Chapter'    xlate('Chapter')        2.25
   'Sect1'      xlate('Section 1')      1.75
   'Sect2'      xlate('Section 2')      1.5
   'Sect3'      xlate('Section 3')      1.25
   'Sect4'      xlate('Section 4')      1
   'Sect5'      xlate('Section 5')      1
   'SimpleSect' xlate('Section 6')      1
   ''           xlate('No section')     1
};

%These two types are no longer used
%as section types

%'FormalPara' 'Titled Paragraph' 1
%'Para' 'Untitled Paragraph' 1
