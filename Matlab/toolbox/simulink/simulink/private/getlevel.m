function Level=getlevel(LevName)
%GETLEVEL Get subsystem level.
%   Level=GETLEVEL(Name) returns the level of a block given the handle or
%   full path name of the block.  Level=0 corresponds to the model.  Level=1
%   corresponds to all blocks on the top level model, etc.

%   Loren Dean
%   Copyright 1990-2002 The MathWorks, Inc.
%   $Revision: 1.8 $

if ~isstr(LevName),
  LevName=getfullname(LevName);
end
NewName=[LevName 0];
Loc=find(NewName=='/');
if ~isempty(Loc),
  NewLoc=find(NewName(Loc+1)=='/');
  LevName([Loc(NewLoc) Loc(NewLoc)+1])='-';
end
Level=length(find(LevName=='/'));
