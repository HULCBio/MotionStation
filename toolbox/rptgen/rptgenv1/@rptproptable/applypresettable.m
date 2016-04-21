function c=applypresettable(r,c,presetName)
%APPLYPRESETTABLE sets a property table component's attributes
%   C=APPLYPRESETTABLE(RPTCOMPONENT,C,PRESETNAME) applies
%   a preset table of name PRESETNAME to C.

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:16:24 $

preset=tableref(c,'GetPresetTable',...
   presetName);

%preset is a structure which has one or many
%fields common with c.att.  Copy over those
%common fields.

oldFieldNames=fieldnames(c.att);
newFieldNames=fieldnames(preset);

[commonfields,oIndex,nIndex]=intersect(...
   oldFieldNames,newFieldNames);

numCommon=length(commonfields);
if numCommon==length(oldFieldNames)
   c.att=preset;
else
   for i=1:numCommon
      c.att=setfield(c.att,commonfields{i},...
         getfield(preset,commonfields{i}));
   end
end

%------------Make sure column display is doubled----
[dispCol,c]=validatecolumns(c);
