function out=getinfo(c)
%GETINFO returns basic component information

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:18:46 $

%---------------- DO NOT EDIT THIS LINE ---------------
out=getprotocomp(c);

%--------------- COMPONENT NAME AND TYPE --------------
out.Name = 'Truth Table';
out.Type = 'SF';
out.Desc =  xlate('Inserts truth table contents into the report');

%---------------------- ATTRIBUTES --------------------
%The out.att.XXX section sets attribute defaults.

out.att.TitleMode = 'none';
out.att.Title = 'Truth Table';

out.att.ShowConditionHeader  = logical(0);
out.att.ShowConditionNumber  = logical(0);
out.att.ShowConditionCode    = logical(0);
out.att.ShowConditionDescription = logical(1);
out.att.ConditionWrapLimit   = 20;

out.att.ShowActionHeader  = logical(0);
out.att.ShowActionNumber  = logical(1);
out.att.ShowActionCode    = logical(1);
out.att.ShowActionDescription = logical(0);

%out.att.FixedWidthCode = logical(1);

%------------------ ATTRIBUTE DISPLAY -----------------
%The out.attx.XXX section sets attribute GUI information.
%Each .attx structure has the following fields:
% .String - Appears as a text field next to the UIcontrol
% .Type - data type of the corresponding attribute.
%      STRING - character string
%      NUMBER - scalar or vector number 
%      LOGICAL - boolean logical(1)/logical(0) 
%      ENUM - enumerated list of STRING, NUMBER, or LOGICAL
%      CELL - cell array 
%      OTHER - structure or object
%         note: "OTHER" has no automated uicontrol updating
% .enumValues - options for an enumerated list (.Type='ENUM')
% .enumNames - display representation of .enumValues
%         note: must be same length as .enumValues
%         note: empty enumNames implies display from enumValues
% .UIcontrol - type of control to use in GUI
% .numberRange - min and max values (.Type-'NUMBER')

out.attx.TitleMode.String='Title';
out.attx.TitleMode.Type='ENUM';
out.attx.TitleMode.UIcontrol='radiobutton';
out.attx.TitleMode.enumValues={'none','auto','manual'};
out.attx.TitleMode.enumNames={xlate('No title'),xlate('Use Stateflow name'),xlate('Manual:')};

out.attx.Title.String='';
out.attx.Title.Type='STRING';
out.attx.Title.UIcontrol='edit';

out.attx.ShowConditionHeader.String = 'Show header';
out.attx.ShowConditionNumber.String = 'Show number';
out.attx.ShowConditionCode.String = 'Show condition';
out.attx.ShowConditionDescription.String = 'Show description';
out.attx.ConditionWrapLimit.String = 'Wrap if column count > ';

out.attx.ShowActionHeader.String = 'Show header';
out.attx.ShowActionNumber.String = 'Show number';
out.attx.ShowActionCode.String = 'Show action';
out.attx.ShowActionDescription.String = 'Show description';

%out.attx.FixedWidthCode = 'Use fixed width font for code';

