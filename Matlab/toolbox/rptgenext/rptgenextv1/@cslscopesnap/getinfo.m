function out=getinfo(c)
%GETINFO returns a structure containing information about the component
%   I=GETINFO(CHGFIGSNAP)
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
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:21:38 $

out=getprotocomp(c);

out.Name = xlate('Block Type: Scope Snapshot');
out.Type = 'SL';
out.Desc = xlate('Inserts pictures of Simulink scopes and XY graphs');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

out.att.isForceOpen=logical(0);
out.att.AutoscaleScope = logical(0);
out.att.PaperOrientation='';
out.att.PaperSize=[5 4];
out.att.PaperUnits='inches';
out.att.isInvertHardcopy=logical(0);
out.att.ImageFormat='AUTOHG';

out.att.CaptionType='$none';
%out.att.CaptionString='';


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

out.attx.isForceOpen.String='';
out.attx.isForceOpen.enumValues={logical(0) logical(1)};
out.attx.isForceOpen.enumNames ={'Include open scopes only'
   'Include all scopes'};
out.attx.isForceOpen.UIcontrol='radiobutton';

out.attx.PaperOrientation.String='Paper orientation ';
out.attx.PaperOrientation.enumValues={
   'portrait'
   'landscape'
   'rotated'
};
out.attx.PaperOrientation.enumNames={
   'Portrait'
   'Landscape'
   'Rotated'
};
out.attx.PaperOrientation.UIcontrol='radiobutton';

allFormats=getimgformat(c,'ALLHG');
out.attx.ImageFormat=struct('String','Image file format',...
   'enumValues',{{allFormats.ID}},...
   'enumNames',{{allFormats.name}});

out.attx.PaperSize.String='Image size: ';

out.attx.PaperUnits.String='';
out.attx.PaperUnits.enumValues={'inches' ...
      'centimeters' 'points' 'normalized'};
out.attx.PaperUnits.UIcontrol='popupmenu';

out.attx.isInvertHardcopy.String=...
   'Use white background and black lines';

out.attx.AutoscaleScope.String = ...
    'Autoscale scopes';

out.attx.CaptionType.String='Caption ';
out.attx.CaptionType.enumValues={'$none','$auto'};
out.attx.CaptionType.enumNames={
   'No caption'
   'Automatic (use block description)'
};
out.attx.CaptionType.UIcontrol='radiobutton';

%out.attx.CaptionString.String='';
%out.attx.CaptionString.isParsedText=logical(1);