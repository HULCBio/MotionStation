function out=getinfo(c)
%GETINFO returns an information structure about the component
%   I=GETINFO(CSLSNAPSHOT)
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
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:21:54 $

out=getprotocomp(c);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

out.Name = xlate('System Snapshot');
out.Type = 'SL';
out.Desc = xlate('Inserts a picture of a Simulink system.');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

out.att.format='AUTOSL';

out.att.TitleType='none';
out.att.TitleString = '';

out.att.CaptionType='$none';
out.att.CaptionString='';

out.att.PaperOrientation='portrait';

out.att.PaperExtentMode='auto';
out.att.PaperExtent= [7 9];
out.att.PaperUnits='inches';

out.att.isPrintFrame=logical(0);
out.att.PrintFrameName='rptdefaultframe.fig';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%-----------------------
%FORMAT
%Image format for the snapshot.
%AUTOSL (the default) references preferences.format.ImageSL
allFormats=getimgformat(c,'ALLSL');
out.attx.format.String='Image file format';
out.attx.format.enumValues={allFormats.ID};
out.attx.format.enumNames={allFormats.name};

out.attx.PaperExtentMode.String='Image size';
out.attx.PaperExtentMode.enumValues={'auto' 'manual'};
out.attx.PaperExtentMode.enumNames={'Automatic',...
      'Manual: '};
%out.attx.PaperWidthMode.UIcontrol='radiobutton';

out.attx.PaperExtent.String='';

out.attx.PaperUnits.String='';
out.attx.PaperUnits.enumValues={'inches' ...
      'centimeters' 'points'};
out.attx.PaperUnits.UIcontrol='popupmenu';

out.attx.isPrintFrame.String='Use printframe: ';

out.attx.PrintFrameName.String='';
out.attx.PrintFrameName.Ext='.fig';

out.attx.PaperOrientation.String='Orientation';
out.attx.PaperOrientation.enumValues={'' ...
      'portrait' 'landscape'};
out.attx.PaperOrientation.enumNames={'Use system orientation' ...
      'Portrait' 'Landscape'};
%out.attx.PaperOrientation.UIcontrol='radiobutton';

%-------
out.attx.CaptionType.String='Caption ';
out.attx.CaptionType.enumValues={'$none','$auto','$manual'};
out.attx.CaptionType.enumNames={
   'No caption'
   'Automatic (use system description)'
   'Manual: '};
out.attx.CaptionType.UIcontrol='radiobutton';

out.attx.CaptionString.String='';
out.attx.CaptionString.isParsedText=logical(1);

%-------
out.attx.TitleType.String='Title ';
out.attx.TitleType.enumValues={'none','sysname','fullsysname','manual'};
out.attx.TitleType.enumNames={
   'No title'
   'System name'
   'System name (full path)'
   'Manual: '};
out.attx.TitleType.UIcontrol='radiobutton';

out.attx.TitleString.String='';
out.attx.TitleString.isParsedText=logical(1);
