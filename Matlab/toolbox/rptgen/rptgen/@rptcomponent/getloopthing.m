function [thing,ok]=getloopthing(c,desiredparent)
%GETLOOPTHING  Extracts loop info from loop parent
%   [THING,OK]=GETLOOPTHING(CURRCOMPONENT,PARENTNAME) 
%   Searches up through the tree structure until it finds
%   a component of name PARENTNAME and extracts the 
%   value set in the parent component by SETLOOPTHING.
% 
%   OK=1 if the loopthing was successfully found
%   OK=0 if the parent was not found
% 
%   SEE ALSO: SETLOOPTHING

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:11:04 $

parent=[];
i=1;
parentStack=subsref(rptcomponent,substruct('.','stack'));

while isempty(parent) & i<=length(parentStack)
   if isa(parentStack{i},desiredparent)
      parent=parentStack{i};
   else
      i=i+1;
   end
end

ok=logical(0);
thing=[];
if isempty(parent)
   status(c,'Warning - failed to find parent',2);
else
   try
      thing=subsref(parent,substruct('.','ref','.','loopthing'));
      ok=logical(1);
   catch
      status(c,'Warning - failed to find loop data in parent',2);
   end   
end