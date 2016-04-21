function list=allcomps(p,varargin)
%ALLCOMPS searches rptcomps.xml to create a list of all components

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:12:09 $

if nargin<2
   regfiles=which('rptcomps.xml','-all');
else
   regfiles=varargin;
end

cnames={};
for i=1:length(regfiles)
   tempList=LocParseRegistry(regfiles{i});
   cnames={cnames{:}, tempList{:}};   
end

hasStateflow=(exist(['sf.',mexext],'file')==3);

entryindex=1;
for i=1:length(cnames)
    
	eval(['mycomp=',cnames{i},';'],'mycomp=[];');
   
   if isa(mycomp,'rptcomponent')     
      info=getinfo(mycomp);
      %entry.Name=info.Name;
      %entry.Type=info.Type;
      %entry.Class=cnames{i};

      if ~(strncmp(info.Type,'SF',2) & ~hasStateflow)
        %If the user does not have stateflow, do not add the stateflow
        %components to the list of valid components.  (Note that they may
        %still work, but we don't want to advertise their existence.)
        
        allValidComps(entryindex)=struct('Name',info.Name,...
         'Type',info.Type,...
         'Class',cnames{i});
        entryindex=entryindex+1;         
      end
 
      delete(mycomp);

   end %if isa component
end %for i=1:length(cnames)

if entryindex>1
   [uNames,uIndex,uAll]=unique({allValidComps.Class});
   allValidComps=allValidComps(uIndex);
   
   [sortedNames,sortedIndex]=sort({allValidComps.Name});
   list=allValidComps(sortedIndex);
else
   list=struct('Class',{},'Name',{},'Type',{});
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function cList=LocParseRegistry(filename)

% Use fopen to avoid checking out the toolbox license keys
fid = fopen(filename,'r');
if fid>0
   regText=char(fread(fid))';
   fclose(fid);
else
   regText='';
end

listText=LocBetweenTag(regText,'complist');
cList=strrep(LocBetweenTag([listText{:},' '],'c')',...
   '&amp;','&');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function between=LocBetweenTag(all,tagname)

between={};
openTag=['<' tagname '>'];
closeTag=['</' tagname '>'];

openLoc=findstr(all,openTag)+length(openTag);
closeLoc=findstr(all,closeTag)-1;

for i=length(openLoc):-1:1
   between{i}=all(openLoc(i):closeLoc(i));   
end
