function out=movecomp(p,action,direction)
%MOVECOMP moves a component in the outline.

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:11:49 $

%p is a pointer to a list of all files in the outline
%action can be "t" for test or "m" for move
%direction can be "u" for up, "d" for down, "i" for in, and "o" for out
%for action=='t', out=the tested DIRECTION
%    action=='m', out=the new value of S
%
%MOVECOMP returns a vector of logicals in "test" mode
%and returns a RPTCP pointer vector with the moved 
%components in "move" mode

if lower(action(1))=='t'
   if nargin<3
      direction={'us' 'ds' 'uo' 'do' 'ui' 'di'};
   elseif ~iscell(direction)
      direction={direction};
   end
   out=isMoveOK(p,direction);      
elseif action=='m'
   %move does not accept vector input
   direction=lower(direction(1:2));
   
   if isMoveOK(p,{direction}) 
      switch direction
      case {'us' 'ds'}
         out=LocMoveUpDown(p,direction);
      case {'uo' 'do'}
         out=LocJumpOut(p,direction);
      case {'ui' 'di'}
         out=LocJumpIn(p,direction);
      otherwise
         out=p;
      end   
   else
      out=p;
   end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function p=LocJumpOut(p,direction)
%we are at the top/bottom of the current loop and want to move up/out

parentIndex=getparent(subset(p,1));
parentRank=rank(parentIndex);
grandparentIndex=getparent(parentIndex);

oldChildren=get(grandparentIndex.h,'Children')';
set(p.h,'Parent',grandparentIndex.h);

if direction(1)=='u' %promote
   set(grandparentIndex.h,'Children',...
      [oldChildren(1:parentRank-1),...
         p.h,...
         oldChildren(parentRank:end)]);
else %demote
   set(grandparentIndex.h,'Children',...
      [oldChildren(1:parentRank),...
         p.h,...
         oldChildren(parentRank+1:end)]);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function p=LocJumpIn(p,direction)

firstP = subset(p,1);
parentIndex=getparent(firstP);
peers=get(parentIndex.h,'Children');

if direction(1)=='d' %get next component
   numPointer=length(p);
   if numPointer>1
      lastP=subset(p,numPointer);
   else
      lastP=firstP;
   end
   
   myRank=rank(lastP);
   neighborHandle=peers(myRank+1);
   oldChildren=[];
else   %get previous component
   myRank=rank(firstP);
   neighborHandle=peers(myRank-1);
   oldChildren=get(neighborHandle,'children')';
end

set(p.h(end:-1:1),'Parent',neighborHandle);

%setting parent puts handles at the beginning of the child
%list.  This is fine for moving in from the top ('d') but
%we need to change move the new handles to the bottom
%when moving in from the bottom.

if ~isempty(oldChildren)
   set(neighborHandle,'children',[oldChildren p.h]);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function p=LocMoveUpDown(p,direction)

firstP=subset(p,1);
lastP =subset(p,'end');

parentIndex=getparent(firstP);

firstRank=rank(firstP);
lastRank=rank(lastP);
allPeers=get(parentIndex,'Children')';

if direction(1)=='u' %move up
   allPeers=[allPeers(1:firstRank-2),...
         allPeers(firstRank:lastRank),...
         allPeers(firstRank-1),...
         allPeers(lastRank+1:end)];
else %move down
   allPeers=[allPeers(1:firstRank-1),...
         allPeers(lastRank+1),...
         allPeers(firstRank:lastRank),...
         allPeers(lastRank+2:end)];
end

set(parentIndex,'children',allPeers);



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function result=isMoveOK(p,direction,ref)

if isoutlineselected(p) | ~isadjacent(p)
   result=logical(zeros(1,length(direction)));
   return;
end

if nargin<3
   ref.firstSelect=subset(p,1);
   pLen=length(p);
   if pLen>1
      ref.lastSelect=subset(p,pLen);
   else
      ref.lastSelect=ref.firstSelect;
   end
   
   parentIndex=getparent(ref.firstSelect);
   parentChildren=get(parentIndex.h,'Children');
      
   %Make a pointer to the next component on the list
   lastRank=rank(ref.lastSelect);
   if (length(parentChildren)==lastRank);
      ref.nextPeer=rptcp([]);
   else
      ref.nextPeer=rptcp(parentChildren(lastRank+1));
   end
   
   %Make a pointer to the previous component on the list
   firstRank=rank(ref.firstSelect);
   if (firstRank==1);
      ref.prevPeer=rptcp([]);
   else
      ref.prevPeer=rptcp(parentChildren(firstRank-1));
   end
   
   %if the parent component is Outline......
   ref.depthOne=(depth(ref.firstSelect)==1);
end

for i=length(direction):-1:1
   result(i)=logical(0);
   
   switch direction{i}
   case 'us'   %up standard
      if ~isempty(ref.prevPeer)
         result(i)=logical(1);
      end
   case 'ds'   %down standard
      if ~isempty(ref.nextPeer)
         result(i)=logical(1);
      end
   case 'uo'   %up out
      if ~ref.depthOne
         result(i)=logical(1);
      end
   case 'do'   %down out
      if isempty(ref.nextPeer) & ~ref.depthOne
         result(i)=logical(1);
      end
   case 'ui'   %up in
      if isparent(ref.prevPeer)
         result(i)=logical(1);
      end 
   case 'di'   %down in
      if isparent(ref.nextPeer)
         result(i)=logical(1);
      end      
   case 'no'
      result(i)=logical(1);
   end %case switch
end %for i=1:length(direction)

if isempty(ref.nextPeer)
   delete(ref.nextPeer);
end

if isempty(ref.prevPeer)
   delete(ref.prevPeer);
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function tf=isadjacent(p)

if length(p)>1
   pvPos=[];
   parentIndex=[];   
   for i=length(p):-1:1
      currP=subset(p,i);
      pvPos(i)=rank(currP);
      parentIndex(i)=double(getparent(currP));
   end
   
   if length(unique(parentIndex))>1
      tf=logical(0);
   else
      tf=isempty(setxor(...
         [min(pvPos):max(pvPos)],pvPos));
   end
   
else
   tf=logical(1);
end


