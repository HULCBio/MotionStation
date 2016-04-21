function c=buildcomponent(c,varargin)
%BUILDCOMPONENT Called during component creation
%   C=BUILDCOMPONENT(C)
%   C=BUILDCOMPONENT(C,STRUCTIN)
%   C=BUILDCOMPONENT(C,'Attribute1',Value1,...)

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:10:50 $

if length(varargin)==1
   if isstruct(varargin{1})...
         & isfield(varargin{1},'comp')...
         & isfield(varargin{1}.comp,'Class')...
         & strcmp(class(c),varargin{1}.comp.Class)      
      %if the incoming variable is struct(c)
      c=LocInfoWrite(c,varargin{1});
   elseif strcmp(class(c),class(varargin{1}))
      %if the incoming variable is a component
      c=varargin{1};
   else
      %ignore the variable
      warning('Warning: Variable not recognized');
      c=LocInfoWrite(c);      
   end
elseif length(varargin)>1
   if mod(length(varargin),2)~=0
      warning('Warning: Number of input arguments not even');
      attPairs=LocMakeAttPairs(varargin(1:end-1));
   else
      attPairs=LocMakeAttPairs(varargin);
   end
   c=LocInfoWrite(c,struct('att',struct(attPairs{:})));
else
   c=LocInfoWrite(c);
end

%note that we actually return a POINTER to 
%the component!
c=rptcp(c);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function c=LocInfoWrite(c,newFields)

i=getinfo(c);
i.comp.Class=class(c);

origFieldNames={'comp' 'att' 'ref' 'x'};
if nargin>1
   [common,oldIndex,newIndex]=intersect(origFieldNames,fieldnames(newFields));
else
   oldIndex=[-1];
end

for j=1:length(origFieldNames)
   oldField=getfield(i,origFieldNames{j});
   if max(find(oldIndex==j))
      oldField=LocStructWrite(oldField,...
         getfield(newFields,origFieldNames{j}));
   end
   %c=c!set(c,origFieldNames{j},oldField);
   c=subsasgn(c,substruct('.',origFieldNames{j}),oldField);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function orig=LocStructWrite(orig,new)
%orig is the structure which comes from GETINFO
%new is the structure from the actual component

if isstruct(orig)
   oldFieldNames=fieldnames(orig);
else
   oldFieldNames={};
end

if isstruct(new)
   newFieldNames=fieldnames(new);
   commonFields=intersect(oldFieldNames,newFieldNames);
   numCommonFields=length(commonFields);
else
   newFieldNames={};
   commonFields={};
   numCommonFields=0;
end

if numCommonFields==length(newFieldNames) & ...
      numCommonFields==length(oldFieldNames)
   %there is 100% overlap between the new fields
   %and the old ones
   orig=new;
%elseif max(newFieldMembers)==0
   %the new structure is empty
else
   for i=1:length(commonFields)
      orig=setfield(orig,commonFields{i},...
         getfield(new,commonFields{i}));
   end   
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function  attPairs=LocMakeAttPairs(attPairs);

for i=2:2:length(attPairs)
   attPairs(i)={attPairs(i)};
end
