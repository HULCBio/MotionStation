function status(c,message,rank)
%STATUS displays status updates during report generation
%   STATUS(cobj,statstring,i) displays "statstring"
%   to the listbox or the command window during generation.
%
%   i is an integer from 1-6 which indicates the
%   urgency of the message.  Users can specify a cutoff
%   importance level for status update messages.
%   1 = errors
%   2 = warnings
%   3 = important events (running a loop)
%   4 = standard events (running a component)
%   5 = low-priority events (running a nested component)
%   6 = other events
%   0 = will not display message
%
%   cobj is any component object
%

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:11:19 $

mlock;

if ischar(message)
   statstring{1}=message;
elseif iscell(message)
   statstring=message;
else
   statstring='';
end

%change the highlighting on the listbox
listboxindex=subsref(c,substruct('.','ref','.','OutlineIndex'));

OutlineListBoxHandle=LocOutlineHandle;
if OutlineListBoxHandle>0 & listboxindex>0 
   set(OutlineListBoxHandle,'Value',listboxindex);
end

%display message to the status update listbox
if ~isempty(statstring)
   StatusListBoxHandle=LocStatusHandle(OutlineListBoxHandle);
   
   persistent RPTGEN_ECHO_DETAIL
   
   if isempty(RPTGEN_ECHO_DETAIL)
      RPTGEN_ECHO_DETAIL=4;
      cParent=subsref(c,substruct('.','ref','.','ID'));
      while isa(cParent,'rptcp')
         cParent=getparent(cParent);            
      end
      if isa(cParent,'rptsp')
         try
            cParent=get(cParent,'UserData');
         catch
            cParent=[];
         end
         
         if isa(cParent,'rptsetupfile')
            try
               RPTGEN_ECHO_DETAIL=cParent.Setfile.EchoDetail;
            end
         end
      end         
   end      


   if StatusListBoxHandle<0
      if rank <= RPTGEN_ECHO_DETAIL
         %we are running from the command line
         for i=1:length(statstring)
            disp(statstring{i})
         end
      end
   else
      %we are running from the GUI
      
      ud=get(StatusListBoxHandle,'UserData');
      udstart=length(ud);
      for i=length(statstring):-1:1
         ud(udstart+i).string=[blanks(rank-1),statstring{i}];
         ud(udstart+i).rank=rank;
      end
      
      currstring=get(StatusListBoxHandle,'String');
      if rank <= RPTGEN_ECHO_DETAIL
         if iscell(currstring)
            currstring(end+1:end+length(statstring))={ud(udstart+1:end).string};
         else
            currstring={ud(udstart:end).string};
         end
      end
            
      set(StatusListBoxHandle,...
         'Value',[],...
         'String',currstring,...
         'UserData',ud,...
         'ListBoxTop',max(length(currstring),1));
   end 
end   


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function h=LocOutlineHandle

persistent RPTGEN_OUTLINE_HANDLE

if length(RPTGEN_OUTLINE_HANDLE)<1 | ...
      (~ishandle(RPTGEN_OUTLINE_HANDLE) & RPTGEN_OUTLINE_HANDLE~=-1)
   RPTGEN_OUTLINE_HANDLE=currgenoutline(rptparent);
end

h=RPTGEN_OUTLINE_HANDLE;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function h=LocStatusHandle(outlineHandle)

persistent RPTGEN_STATUS_HANDLE

if length(RPTGEN_STATUS_HANDLE)<1 | ...
      (~ishandle(RPTGEN_STATUS_HANDLE) & RPTGEN_STATUS_HANDLE~=-1)
   if ishandle(outlineHandle)
      figH=get(outlineHandle,'parent');
      
      lbH=findall(figH,...
         'Style','listbox',...
         'Tag','StatusReport');
      
      if isempty(lbH)
         RPTGEN_STATUS_HANDLE=-1;
      else
         RPTGEN_STATUS_HANDLE=lbH(1);
      end
   else
      RPTGEN_STATUS_HANDLE=-1;
   end
end

h=RPTGEN_STATUS_HANDLE;