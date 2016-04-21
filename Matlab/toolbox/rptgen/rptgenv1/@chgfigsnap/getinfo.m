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
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:14:20 $

out=getprotocomp(c);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

out.Name = xlate('Graphics Figure Snapshot');
out.Type = 'HG';
out.Desc = xlate('Inserts a picture of a figure.');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

out.att.FigureHandle=[];

out.att.isCapture=logical(0);
out.att.PaperOrientation='';
out.att.isResizeFigure='auto';
out.att.PrintSize=[3.75 3];
out.att.PrintUnits='inches';
out.att.InvertHardcopy='auto';
out.att.ImageFormat='AUTOHG';
out.att.ImageTitle='';
out.att.Caption='';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

allFormats=getimgformat(c,'ALLHG');
out.attx.ImageFormat=struct('String','Image file format',...
   'enumValues',{{allFormats.ID}},...
   'enumNames',{{allFormats.name}});

out.attx.isCapture.String='Capture figure from screen';

out.attx.isResizeFigure.String='Image size ';
out.attx.isResizeFigure.enumValues={'' 'auto' 'manual'};
out.attx.isResizeFigure.enumNames={...
      'Use figure PaperPositionMode setting' ...
      'Automatic (same size as on-screen)' ...
      'Manual: '};
out.attx.isResizeFigure.UIcontrol='radiobutton';

out.attx.PrintSize.String='';

out.attx.PaperOrientation.String='Paper orientation ';
out.attx.PaperOrientation.enumValues={'' ...
      'portrait' 'landscape','rotated'};
out.attx.PaperOrientation.enumNames={'Use figure orientation' ...
      'Portrait' 'Landscape','Rotated'};
out.attx.PaperOrientation.UIcontrol='popupmenu';

out.attx.PrintUnits.String='';
out.attx.PrintUnits.enumValues={'inches' ...
      'centimeters' 'points' 'normalized'};

out.attx.InvertHardcopy.String='Invert hardcopy ';
out.attx.InvertHardcopy.enumValues={'auto' 'on' 'off' ''};
out.attx.InvertHardcopy.enumNames={'Automatic' ...
      'Invert' ...
      'Don''t invert' ...
      'Use figure''s InvertHardcopy setting'};
out.attx.InvertHardcopy.UIcontrol='popupmenu';


out.ref.captureImageExt={'tif'
   'tiff'
   'jpg'
   'jpeg'
   'bmp'
   'png'
   'hdf'
   'pcx'
   'xwd'};