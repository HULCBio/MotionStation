function [currentState, logP] = hmmviterbi(seq,tr,e,varargin)
%HMMVITERBI calculates the most probable state path for a sequence.
%   STATES = HMMVITERBI(SEQ,TRANSITIONS,EMISSIONS) given a sequence, SEQ,
%   calculates the most likely path through the Hidden Markov Model
%   specified by transition probability matrix, TRANSITIONS, and emission
%   probability matrix, EMISSIONS. TRANSITIONS(I,J) is the probability of
%   transition from state I to state J. EMISSIONS(K,L) is the probability
%   that symbol L is emitted from state K. 
%
%   HMMVITERBI(...,'SYMBOLS',SYMBOLS) allows you to specify the symbols
%   that are emitted. SYMBOLS can be a numeric array or a cell array of the
%   names of the symbols.  The default symbols are integers 1 through N,
%   where N is the number of possible emissions.
%
%   HMMVITERBI(...,'STATENAMES',STATENAMES) allows you to specify the
%   names of the states. STATENAMES can be a numeric array or a cell array
%   of the names of the states. The default statenames are 1 through M,
%   where M is the number of states.
%
%   This function always starts the model in state 1 and then makes a
%   transition to the first step using the probabilities in the first row
%   of the transition matrix. So in the example given below, the first
%   element of the output states will be 1 with probability 0.95 and 2 with
%   probability .05.
%
%   Examples:
%
% 		tr = [0.95,0.05;
%             0.10,0.90];
%           
% 		e = [1/6,  1/6,  1/6,  1/6,  1/6,  1/6;
%            1/10, 1/10, 1/10, 1/10, 1/10, 1/2;];
%
%       [seq, states] = hmmgenerate(100,tr,e);
%       estimatedStates = hmmviterbi(seq,tr,e);
%
%       [seq, states] = hmmgenerate(100,tr,e,'Statenames',{'fair';'loaded'});
%       estimatesStates = hmmviterbi(seq,tr,e,'Statenames',{'fair';'loaded'});
%
%   See also HMMGENERATE, HMMDECODE, HMMESTIMATE, HMMTRAIN.

%   Reference: Biological Sequence Analysis, Durbin, Eddy, Krogh, and
%   Mitchison, Cambridge University Press, 1998.  

%   Copyright 1993-2004 The MathWorks, Inc.
%   $Revision: 1.3.4.1 $  $Date: 2003/11/01 04:26:33 $

% tr must be square

numStates = size(tr,1);
checkTr = size(tr,2);
if checkTr ~= numStates
    error('stats:hmmviterbi:BadTransitions',...
          'TRANSITION matrix must be square.');
end

% number of rows of e must be same as number of states

checkE = size(e,1);
if checkE ~= numStates
    error('stats:hmmviterbi:InputSizeMismatch',...
         'EMISSIONS matrix must have the same number of rows as TRANSITIONS.');
end

numEmissions = size(e,2);
customStatenames = false;

% deal with options
if nargin > 3
    if rem(nargin,2)== 0
        error('stats:hmmviterbi:WrongNumberArgs',...
              'Incorrect number of arguments to %s.',mfilename);
    end
    okargs = {'symbols','statenames'};
    for j=1:2:nargin-3
        pname = varargin{j};
        pval = varargin{j+1};
        k = strmatch(lower(pname), okargs);
        if isempty(k)
            error('stats:hmmviterbi:BadParameter',...
                  'Unknown parameter name:  %s.',pname);
        elseif length(k)>1
            error('stats:hmmviterbi:BadParameter',...
                  'Ambiguous parameter name:  %s.',pname);
        else
            switch(k)
                case 1  % symbols
                    symbols = pval;  
                    numSymbolNames = numel(symbols);
                    if length(symbols) ~= numSymbolNames
                        error('stats:hmmviterbi:BadSymbols',...
                              'SYMBOLS must be a vector');
                    end
                    if numSymbolNames ~= numEmissions
                        error('stats:hmmviterbi:BadSymbols',...
                          'Number of Symbols must match number of emissions.');
                    end     
                    [dummy, seq]  = ismember(seq,symbols);
                    
                case 2  % statenames
                    statenames = pval;
                    numStateNames = length(statenames);
                    if numStateNames ~= numStates
                        error('stats:hmmviterbi:BadStateNames',...
                     'Number of Statenames must match the number of states.');
                    end
                    customStatenames = true;
            end
        end
    end
end

% work in log space to avoid numerical issues
L = length(seq);
currentState = zeros(1,L);
if L == 0
    return
end
w = warning('off'); % get log of zero warnings
logTR = log(tr);
logE = log(e);
warning(w);

% allocate space

pTR = zeros(numStates,L);
% assumption is that model is in state 1 at step 0
v = repmat(-inf, numStates,1);
v(1,1) = 0;
vOld = v;

% loop through the model
for count = 1:L
    for state = 1:numStates
        % for each state we calculate
        % v(state) = e(state,seq(count))* max_k(vOld(:)*tr(k,state));
        bestVal = -inf;
        bestPTR = 0;
        % use a loop to avoid lots of calls to max
        for inner = 1:numStates 
            val = vOld(inner) + logTR(inner,state);
            if val > bestVal
                bestVal = val;
                bestPTR = inner;
            end
        end
        % save the best transition information for later backtracking
        pTR(state,count) = bestPTR;
        % update v
        v(state) = logE(state,seq(count)) + bestVal;
    end
    vOld = v;
end

% decide which of the final states is post probable
[logP, finalState] = max(v);

% Now back trace through the model
currentState(L) = finalState;

for count = L-1:-1:1
    currentState(count) = pTR(currentState(count+1),count+1);
end

if customStatenames
    currentState = reshape(statenames(currentState),1,L);
end


