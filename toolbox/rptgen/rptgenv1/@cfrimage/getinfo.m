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
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:13:22 $

out=getprotocomp(c);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

out.Name = xlate('Image');
out.Type = 'FR';
out.Desc = xlate('Inserts an image into the document.');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

out.att.isTitle='none';
out.att.Title=xlate('Report Generator Image');
out.att.FileName='ngc6543a.jpg';
out.att.Caption='';
out.att.isInline=logical(0);
out.att.CalloutList=cell(0,2);
out.att.isCopyFile=logical(0);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

out.attx.isTitle=struct('String','',...
   'enumValues',{{'none' 'local' 'filename'}},...
   'enumNames',{{'No title' 'Title:' 'Title from filename'}},...
   'UIcontrol','radiobutton');

out.attx.FileName.String = '';
out.attx.FileName.Ext='*';
out.attx.FileName.isParsedText=logical(1);

out.attx.isInline.String='Insert as inline image';

out.attx.Title.String='';

out.attx.isCopyFile.String=...
   'Copy to local report files directory';

%CalloutList is an Nx2 cell array containing pairs of
%[x y width height] coordinates and callout text
%Callout text can contain links.