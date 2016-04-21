function parents = selectiontournament(expectation,nParents,options,tournamentSize)
%SELECTIONTOURNAMENT Each parent is the best of a random set.
%   PARENTS = SELECTIONTOURNAMENT(EXPECTATION,NPARENTS,OPTIONS,TOURNAMENTSIZE)
%   chooses the PARENTS by selecting the best TOURNAMENTSIZE players out of 
%   NPARENTS with EXPECTATION and then choosing the best individual 
%   out of that set.
%
%   Example:
%   Create an options structure using SELECTIONTOURNAMENT as the selection
%   function and use the default TOURNAMENTSIZE of 4
%     options = gaoptimset('SelectionFcn',@selectiontournament); 
%
%   Create an options structure using SELECTIONTOURNAMENT as the
%   selection function and specify TOURNAMENTSIZE to be 3.
%
%     tournamentSize = 3;
%     options = gaoptimset('SelectionFcn', ...
%               {@selectiontournament, tournamentSize});

%   Copyright 2004 The MathWorks, Inc.
%   $Revision: 1.6 $  $Date: 2004/01/16 16:51:29 $

%how many players in each tournament?
if(nargin < 4)
    tournamentSize = 4;
end

%choose the players
players = ceil(length(expectation) * rand(nParents,tournamentSize));

% look up the outcomes
scores = expectation(players);

% pick the winners
[unused,m] = max(scores');

%m is now the index of the winners;
parents = zeros(1,nParents);
for i = 1:nParents
    parents(i) = players(i,m(i));
end