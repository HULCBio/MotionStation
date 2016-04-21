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
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:18:32 $

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

out=getprotocomp(c);

out.Name = xlate('Snapshot');
out.Type = 'SF';
out.Desc = xlate('Inserts a picture of a Stateflow object');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

out.att.imageSizing='auto';
out.att.PrintSize=[500 300];
out.att.PrintSizePoints = out.att.PrintSize;
out.att.picMinChildren = 0;
out.att.PrintUnits='points';
out.att.ImageFormat='AUTOSF';
out.att.isCallouts=logical(1);
out.att.TitleType='none';
out.att.TitleString = '';


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

out.attx.picMinChildren.String = ...
   'Run only if Stateflow object has at least the following number of children:';

allFormats=getimgformat(c,'ALLSF');
out.attx.ImageFormat=struct('String','Image file format',...
   'enumValues',{{allFormats.ID}},...
   'enumNames',{{allFormats.name}});

out.attx.imageSizing.String='';
out.attx.imageSizing.enumValues={'auto' 'manual'};
out.attx.imageSizing.enumNames={...
      ['Attempt to shrink image to minimum font size set in Stateflow Loop'] ...
      'As specified (maintain aspect ratio)'};
out.attx.imageSizing.UIcontrol='radiobutton';

out.attx.PrintSize.String='Maximum size';

out.attx.PrintUnits.String='';
out.attx.PrintUnits.enumValues={'inches' 'centimeters' 'points'};

out.attx.isCallouts.String='Include callouts to describe visible objects';

%-------
out.attx.TitleType.String='Title ';
out.attx.TitleType.enumValues={'none','objname','fullsfname','fullslsfname','manual'};
out.attx.TitleType.enumNames={
   'No title'
   'Object name'
   'Object name (full Stateflow path)'
   'Object name (full Simulink+Stateflow path)'
   'Manual: '};
out.attx.TitleType.UIcontrol='radiobutton';

out.attx.TitleString.String='';
out.attx.TitleString.isParsedText=logical(1);
