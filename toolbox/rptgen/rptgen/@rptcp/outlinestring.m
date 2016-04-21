function strout=outlinestring(p,updateLabel)
%OUTLINESTRING creates each line of the editor outline
%   OLSTR=OUTLINESTRING(RPTCP)
%   OLSTR=OUTLINESTRING(RPTCP,REFRESH)
%        REFRESH=0 (default) does not update the stored LABEL
%        REFRESH=1 updates the stored LABEL
%        REFRESH=2 updates the LABEL and the outline entry

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:11:54 $

if nargin<2
   updateLabel=logical(0);
   updateOutline=logical(0);
elseif updateLabel>1
   updateOutline=logical(1);
else
   updateOutline=logical(0);
end

d=depth(p);

if updateOutline
   try
      outlineHandle=outlinehandle(rptsp(p));
      outlineString=get(outlineHandle,'String');
      oldProp.Value=get(outlineHandle,'Value');
      oldProp.ListBoxTop=get(outlineHandle,'ListBoxTop');
   catch
      updateOutline=0;
   end
end

for i=length(p.h):-1:1
   c=get(p.h(i),'UserData');
   
   if c.comp.Active==2
      boxText='+';
   elseif c.comp.Active==0
      boxText=' !';
      %this is Ø, a zero with a diagonal slash
   else %if active==1
      if isparent(c)
         boxText=' -';
      else
         boxText='  ';
      end      
   end
   
   if updateLabel
      try
         listEntry=outlinestring(c);
      catch
         listEntry=c.comp.Class;
      end      
      set(p.h(i),'Label',listEntry);
   else
      listEntry=get(p.h(i),'Label');
   end

   %spacer = blanks(3*d(i));m
   spacer='';
   for j=d(i):-1:1
     spacer((j-1)*3+1:j*3)=' . ';    
   end
   
   strout{i}=sprintf('%s[%s] %s',...
       spacer,...
       boxText,...
       listEntry);
   
   if updateOutline
      try
         outlineIndex=c.ref.OutlineIndex;
      catch
         outlineIndex=[];
      end
      if ~isempty(outlineIndex) & ...
            outlineIndex(1)>0 
         outlineString{outlineIndex(1)}=strout{i};
      end
   end
end

if updateOutline
   set(outlineHandle,oldProp,'String',outlineString);
end


%if length(strout)==1
%   strout=strout{i};
%end

