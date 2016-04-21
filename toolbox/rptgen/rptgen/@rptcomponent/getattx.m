function a=getattx(c,attname)
%GETATTX returns information about component attributes
%   i=GETATTX(C,'ATTNAME') where C is a report generator
%   component returns an information structure about a
%   component attribute.
%
%   i.Name - attribute name
%   i.Type - data type
%   i.enumValues - value options for ENUM type
%   i.enumNames - string representation of enumValues
%   i.UIcontrol - uicontrol type for attribute page
%   i.Ext - file extension for uicontrol=filebrowse
%   i.String - string description of attribute
%
%   See also: RPTCOMPONENT/CONTROLSMAKE, RPTCOMPONENT/CONTROLSUPDATE
%

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:11:00 $

info=getinfo(c);


if isfield(info,'attx') & isfield(info.attx,attname)
   a=getfield(info.attx,attname);
else
   a=[];
end

a.Default=getfield(info.att,attname);
a.Current=subsref(c,substruct('.','att','.',attname));
a.Name=attname;

if ~isfield(a,'String')
   a.String=a.Name;
end

if ~isfield(a,'Type')
   if islogical(a.Default)
      a.Type='LOGICAL';
   elseif isfield(a,'enumValues')...
         & ~isempty(a.enumValues)
      a.Type='ENUM';
   elseif isfield(a,'Ext') ...
         & ~isempty(a.Ext)
      a.Type='STRING';
      a.UIcontrol='filebrowse';
   elseif isnumeric(a.Default)
      a.Type='NUMBER';
   elseif ischar(a.Default)
      a.Type='STRING';
   elseif iscell(a.Default)
      a.Type='CELL';
   else
      a.Type='OTHER';
   end
end

if ~isfield(a,'enumValues')
   if strcmp('LOGICAL',a.Type)
      a.enumValues={logical(1) logical(0)};
   else           
      a.enumValues={};
   end
end

if ~isfield(a,'enumNames')
   if strcmp('LOGICAL',a.Type)
      a.enumNames={'True' 'False'};
   else
      a.enumNames=a.enumValues;
   end
end

if ~isfield(a,'UIcontrol')
   switch a.Type
   case 'ENUM'
      a.UIcontrol='popupmenu';
   case 'LOGICAL'
      a.UIcontrol='checkbox';
   otherwise
      a.UIcontrol='edit';      
   end      
end

if ~isfield(a,'Ext')
   a.Ext='*';
end

if ~isfield(a,'numberRange')
   if ~strcmpi(a.Type,'NUMBER')
      nRange=[0 1];
   else
      nRange=[min(0,a.Default) max(1,a.Default)];
   end
   a.numberRange=nRange;
end

if ~isfield(a,'isParsedText')
   a.isParsedText=logical(0);
end
