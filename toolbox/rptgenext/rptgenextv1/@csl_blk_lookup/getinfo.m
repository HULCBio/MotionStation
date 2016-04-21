function out=getinfo(c)
%GETINFO returns a structure containing information about the component
%   I=GETINFO(CSL_BLK_LOOKUP)
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
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:19:28 $

out=getprotocomp(c);

out.Name = xlate('Block Type: Look-Up Table');
out.Type = 'SL';
out.Desc = xlate('Displays 1-D/2-D/N-D look-up table blocks as images and/or tables');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

out.att.isSinglePlot=logical(1);
out.att.SinglePlotType='lineplot';
out.att.isSingleTable=logical(0);

out.att.isDoublePlot=logical(0);
out.att.DoublePlotType='surfaceplot';
out.att.isDoubleTable=logical(0);

out.att.isMultiTable = logical(0);

out.att.TitleType = 'none';
out.att.TitleString ='Look-Up Table';

out.att.ImageFormat='AUTOHG';
out.att.PaperOrientation='portrait';
out.att.PrintSize=[5 4];
out.att.PrintUnits='inches';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

out.attx.isSinglePlot.String='Plot 1-D data';

out.attx.SinglePlotType.String='';
out.attx.SinglePlotType.enumValues={
   'lineplot'
   'barplot'
};
out.attx.SinglePlotType.enumNames={
   'Line plot'
   'Bar plot'
};

out.attx.isSingleTable.String='Create table for 1-D data';

out.attx.isDoublePlot.String='Plot 2-D data';

out.attx.DoublePlotType.String='';
out.attx.DoublePlotType.enumValues={
   'multilineplot'
   'surfaceplot'
};
out.attx.DoublePlotType.enumNames={
   'Multi-line plot'
   'Surface plot'
};

out.attx.isDoubleTable.String='Create table for 2-D data';

allFormats=getimgformat(c,'ALLHG');
out.attx.ImageFormat=struct('String','Image file format',...
   'enumValues',{{allFormats.ID}},...
   'enumNames',{{allFormats.name}});

out.attx.isMultiTable.String='Create table for N-D data';

%------------------------------------
out.attx.TitleType.String = '';
out.attx.TitleType.enumValues={'none','auto','manual'};
out.attx.TitleType.enumNames={
   'No title',
   'Auto: title from block name',
   'Manual: '
};
out.attx.TitleType.UIcontrol='radiobutton';
   
out.attx.TitleString.String='';

%------------------------------------
out.attx.PaperOrientation.String='Paper orientation';
out.attx.PaperOrientation.enumValues={
   'portrait'
   'landscape'
};
out.attx.PaperOrientation.enumNames={
   'Portrait'
   'Landscape'
};
out.attx.PaperOrientation.UIcontrol='popupmenu';

out.attx.PrintSize.String='Image size';

out.attx.PrintUnits.String='';
out.attx.PrintUnits.enumValues={'inches' ...
      'centimeters' 'points' 'normalized'};

