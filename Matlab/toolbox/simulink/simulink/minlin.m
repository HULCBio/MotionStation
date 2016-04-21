function [ma, mb, mc]=minlin(A, B, C)
%MINLIN Removes unconnected states from state-space matrices.
%   [Ar,Br,Cr]=MINLIN(A,B,C)removes elements in A, B, and C that are
%   unconnected which cause unobservable and uncontrollable states.
%
%   Note: this function does not remove all states caused by pole-zero 
%   cancellation. The purpose is to remove states that are caused by not being 
%   in the input-output path. These often result from linearization of a block 
%   diagram where not all blocks are in the input-output path.
%
%   See also LINMOD and MINREAL in the Control System Toolbox.

%   A.C.W. Grace 7-31-97
%   Copyright 1990-2002 The MathWorks, Inc.
%   $Revision: 1.6 $


% First remove uncontrollable states i.e. states which
% the inputs have no affect over.

% Find dependencies on inputs by looking at the elements in
% the B vector which affect the states. Definitely
% keep those states by putting them in keepList.
[nx, nu] = size(B);  % number of states and inputs
keepList = find(any(B,2));

removeList = (1:nx)'; % the states that are to be removed
removeList(keepList) = [];
newKeepList  = keepList;
while ~isempty(newKeepList)
   % Now look at which states are affected by the states
   % that in turn are affected by the inputs and
   % add these to the list. This is done by looking down
   % the columns of the remaining states.
   newKeepList = removeList(find(any(A(removeList, keepList), 2)));
   keepList = [keepList; newKeepList];
   removeList = (1:nx)';
   removeList(keepList) = [];  % the list of states to remove gets smaller
end

% Now we've located them, remove all uncontrollable states
keepList = sort(keepList);
A = A(keepList, keepList);
B = B(keepList,:);
C = C(:, keepList);
[nx, nu] = size(B);

% Now remove all unobservable states
keepList = find(any(C,1))';
removeList = (1:nx)';   % the new list of states to remove
removeList(keepList) = [];
newKeepList = keepList;
while ~isempty(newKeepList)
  % This time look at states which can somehow affect the
  % output. This starts off with the index from the C vector
  % and the list grows as we find more states that in turn
  % can affect each other. This is done by looking down the
  % rows of the remaining states.
  newKeepList = removeList(find(any(A(keepList, removeList), 1)));
  keepList = [keepList; newKeepList];

  removeList = (1:nx)';
  removeList(keepList) = [];
end

% Now remove all unobservable states
keepList = sort(keepList);
ma = A(keepList, keepList);
mb = B(keepList,:);
mc = C(:, keepList);
