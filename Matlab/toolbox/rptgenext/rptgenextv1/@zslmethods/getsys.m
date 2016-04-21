function subsystems=getsys(c,type,startsys,showblocks)
%SUBSYSTEMS returns a list of Simulink systems
%   SUBSYSTEMS(cobj,listtype,includeblocks) returns a list
%   of SIMULINK subsystems
%
%   list(i).fullname
%   list(i).depth
%   list(i).blockname
%   list(i).type= s or b
%   list(i).indentname
%
%   coobj is a component object
%
%   listtype can be "ALL","CURRENT","TOP","CURRENTABOVE",
%   "CURRENTBELOW", or "CUSTOM".
%
%   startsys is the system from which to start the list build
%
%   includeblocks is a boolean value.  True will cause 
%   non-system blocks to be included in the list.

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:22:36 $

cstruc=struct(c);

if strcmp(startsys,'CURRENT')
   startsys=gcs;
elseif strcmp(startsys,'TOP')
   startsys=bdroot;
end

%generate cell array list of subsystems
if ~isempty(gcs)
   switch upper(type)
   case 'ALL'
      subsystems= locmakesyslist(c,bdroot,'down',showblocks);
   case 'START'
      subsystems=locflesh({startsys});
   case 'STARTABOVE'
      subsystems = locmakesyslist(c,startsys,'up',showblocks);
   case 'STARTBELOW'
      subsystems = locmakesyslist(c,startsys,'down',showblocks);
   case 'CUSTOM'
      subsystems = locflesh(cstruc.att.customlist);
   end %switch
else
   subsystems=[];
end %if

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function list=locflesh(fullnames)

if length(fullnames)>0
   for i=1:length(fullnames)
      entry.fullname=fullnames{i};
      entry.depth=length(findstr('/',fullnames{i}));
      entry.blockname=locblockname(fullnames{i});
      entry.type='s';
      entry=LocIndentName(entry);
      list(i)=entry;
   end
else
   list=[];
end
   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function entry=LocIndentName(entry);

nojunkname=strrep(entry.blockname,sprintf('\n'),' ');
entry.indentname=[char(' '*ones(1,4*entry.depth)),nojunkname];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function list=locmakesyslist(c,startcomp,direction,showblocks)

entry.fullname=startcomp;
entry.depth=length(findstr('/',startcomp));
entry.blockname=locblockname(entry.fullname);
entry.type='s';
entry=LocIndentName(entry);

list=loclist(entry,direction,showblocks);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function list=loclist(list,direction,showblocks)

index = length(list);

if strcmp(direction,'up')
   parent=get_param(list(index).fullname,'Parent');
   if isempty(parent)
      list=list;
   else
      entry.fullname=parent;
      entry.depth=list(index).depth-1;
      entry.blockname=locblockname(entry.fullname);
      entry.type='s';      
      entry=LocIndentName(entry);

      list(length(list)+1)=entry;
      list=loclist(list,direction,showblocks);
   end         
else
   try
      blocks = get_param(list(index).fullname,'Blocks');
   catch
      blocks = {};
   end
   
   for i=1:length(blocks)
      %more reliable but slower to use getfullname???
      entry.fullname = [list(index).fullname,'/',blocks{i}];
      entry.depth = list(index).depth+1;
      entry.blockname = locblockname(blocks{i});
      try 
         %if this is successful, this is a system
         get_param(entry.fullname,'Blocks');
         entry.type='s';
         entry=LocIndentName(entry);
         list(length(list)+1) = entry;
         list = loclist(list,direction,showblocks);
      catch
         %otherwise, it is just a plain old block
         if showblocks
            entry.type='b';
            entry=LocIndentName(entry);
            list(length(list)+1) = entry;
         end %if showblocks         
      end %try catch            
   end %for i=1:length(blocks)
end %if  

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function shortname=locblockname(longname);

slashes=findstr('/',longname);
if isempty(slashes)
   shortname=longname;
else   
   lastslash=slashes(length(slashes));
   namelength=length(longname);
   shortname=longname(lastslash+1:namelength);
end
shortname=strrep(shortname,sprintf('\n'),' ');
