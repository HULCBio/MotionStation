function list=allcomptypes(p,varargin)
%ALLCOMPTYPES searches rptcomps.xml to return list of all component types

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:12:10 $

if nargin<2
   regfiles=which('rptcomps.xml','-all');
else
   regfiles=varargin;
end

idList={};
nameList={};
for i=1:length(regfiles)
   [tempID, tempName]=LocParseRegistry(regfiles{i});
   idList={idList{:},tempID{:}};
   nameList={nameList{:},tempName{:}};   
end

list=struct('Type',idList,'Fullname',nameList,'Expand',logical(1));

[sortedNames,sortedIndex]=sort(nameList);
list=[list(sortedIndex)];

i=1;
while i<length(list)
   if strcmp(list(i).Type,list(i+1).Type)
      list=[list(1:i), list(i+2:end)];
   else
      i=i+1;
   end
end




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [idText,nameText]=LocParseRegistry(filename)

% Use fopen to avoid checking out the toolbox license keys
fid = fopen(filename,'r'); 
if fid>0
   regText=char(fread(fid))';
   fclose(fid);
else
   regText='';
end


regText=LocBetweenTag(regText,'registry');

%-------get component type ID/name----------
typeText=LocBetweenTag([regText{:} ' '],'typelist');
idText=strrep(LocBetweenTag([typeText{:} ' '],'id'),...
   '&amp;','&');
nameText=strrep(LocBetweenTag([typeText{:} ' '],'name'),...
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
