function out=runcomponent(p,GenStatusRank)
%RUNCOMPONENT  Executes a Report Generator component
%   RUNCOMPONENT(P,n) runs all components pointed to
%   by the pointer P.  The rank of this action is
%   echoed in the "Generation Status" tab with rank
%   n where n is a number 1-6.  n==0 results in no
%   generation status message being posted.
%
%   RUNCOMPONENT(P) runs all components pointed to
%   by the pointer P with generation status rank 4.

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:11:57 $

c=get(p.h,'UserData');
if ~iscell(c)
   c={c};
end

if nargin<2
   GenStatusRank=4;
end

r=rptcomponent;

out{length(c)}='';
%toRunComponents=find(cellfun('isclass',c,'rptcomponent'));

%for i=1:length(toRunComponents)
for i=1:length(c)
   if isa(c{i},'rptcomponent') & isactive(c{i}) & ~r.HaltGenerate
      if GenStatusRank>0
         info=getinfo(c{i});
         status(c{i},...
            sprintf('Running component %s.',info.Name),GenStatusRank);
         pause(0)  %drawnow-allows listbox to update
      else
         info=[];
      end
      
      hList=r.stack.h;
      r.stack.h=[hList p.h(i)];
      try
         out{i}=execute(c{i});
      catch
         %if there was an error executing the component
         countharderrors(p,1);
         if isempty(info)
            info=getinfo(c{i});
         end
         
         errString=strrep(lasterr,sprintf('\n'),' ');
         
         status(c{i},sprintf('Error in component %s : %s',info.Name,errString),1);
      end
      hList=r.stack.h;
      r.stack.h=hList(1:end-1);
   end
end

if length(out)==1
   out=out{1};
else
%   out=sgmltag(out{:});
end