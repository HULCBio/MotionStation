function out=getinfo(c)
%GETINFO returns a structure containing information about the component
%   I=GETINFO(CRGTDS)
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
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:16:33 $

out=getprotocomp(c);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

out.Name = xlate('Time/Date Stamp');
out.Type = 'RG';
out.Desc = xlate('Displays the time and date of generation.');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

out.att.isprefix=logical(1);
out.att.prefixstring=xlate('Created ');

out.att.istime=logical(1);
out.att.timeformat=12;
out.att.timesec=logical(0);
out.att.timesep=':';

out.att.isdate=logical(1);
out.att.dateorder='DMY';
out.att.datesep=' ';
out.att.datemonth='LONG';
out.att.dateyear='LONG';

%out.att.linebreakafter=logical(1);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

out.attx.prefixstring.String='';
out.attx.isprefix.String='Include text before stamp: ';
out.attx.istime.String='Include current time in stamp';
out.attx.isdate.String='Include current date in stamp';
out.attx.timesec.String='Include seconds in time stamp';

out.attx.timesep=struct('String','Time separator',...
   'enumValues',{{'&nbsp;' ':' '.' ''}},...
   'enumNames',{{'Blank space ( )'
      'Colon (:)'
      'Period (.)'
      'None ()'}});

out.attx.datesep=struct('String','Date separator',...
   'enumValues',{{'&nbsp;' ':' '//' '.' ''}},...
   'enumNames',{{'Blank space ( )'
      'Colon (:)'
      'Slash (/)'
      'Period (.)'
      'None ()'}});

out.attx.dateorder=struct('String','Date order',...
   'enumValues',{{'DMY' 'MDY' 'YMD'}},...
   'enumNames',{{'Day Month Year'
      'Month Day Year'
      'Year Month Day'}});

out.attx.dateyear=struct('String','Year display',...
   'Type','ENUM',...
   'enumValues',{{'LONG' 'SHORT'}},...
   'enumNames',{{'Long (1998)' 'Short (98)'}});

out.attx.datemonth=struct('String','Month display',...
   'enumValues',{{'LONG' 'SHORT' 'NUM'}},...
   'enumNames',{{'Long (December)'
      'Short (Dec)' 
      'Numeric (12)'}});

out.attx.timeformat=struct('String','Time display',...
   'Type','ENUM',...
   'enumValues',{{12 24}},...
   'enumNames',{{'12-hour'
      '24-hour'}});