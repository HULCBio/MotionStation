function [seq,  states]= hmmgenerate(L,tr,e,varargin)
%HMMGENERATE generate a sequence for a Hidden Markov Model
%   [SEQ, STATES] = HMMGENERATE(LEN,TRANSITIONS,EMISSIONS) generates
%   sequence of emission symbols, SEQ, and a random sequence of states,
%   STATES, of length LEN from a Markov Model specified by transition
%   probability matrix, TRANSITIONS, and EMISSION probability matrix,
%   EMISSIONS. TRANSITIONS(I,J) is the probability of transition from state
%   I to state J. EMISSIONS(K,L) is the probability that symbol L is
%   emitted from state K. 
%
%   HMMGENERATE(...,'SYMBOLS',SYMBOLS) allows you to specify the symbols
%   that are emitted. SYMBOLS can be a numeric array or a cell array of the
%   names of the symbols. The default symbols are integers 1 through N,
%   where N is the number of possible emissions.
%
%   HMMGENERATE(...,'STATENAMES',STATENAMES) allows you to specify the
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
%       [seq, states] = hmmgenerate(100,tr,e)
%
%       [seq, states] = hmmgenerate(100,tr,e,'Symbols',...
%                 {'one','two','three','four','five','six'},...
%                  'Statenames',{'fair';'loaded'})
%
%   See also  HMMVITERBI, HMMDECODE, HMMESTIMATE, HMMTRAIN.

%   Copyright 1993-2004 The MathWorks, Inc. 
%   $Revision: 1.3.4.2 $  $Date: 2003/12/04 19:05:53 $

seq = zeros(1,L);
states = zeros(1,L);

% tr must be square

numStates = size(tr,1);
checkTr = size(tr,2);
if checkTr ~= numStates
    error('stats:hmmgenerate:BadTransitions',...
          'TRANSITION matrix must be square.');
end

% number of rows of e must be same as number of states

checkE = size(e,1);
if checkE ~= numStates
    error('stats:hmmgenerate:InputSizeMismatch',...
         'EMISSIONS matrix must have the same number of rows as TRANSITIONS.');
end

numEmissions = size(e,2);

customSymbols = false;
customStatenames = false;

if nargin > 3
    if rem(nargin,2)== 0
        error('stats:hmmgenerate:WrongNumberArgs',...
              'Incorrect number of arguments to %s.',mfilename);
    end
    okargs = {'symbols','statenames'};
    for j=1:2:nargin-3
        pname = varargin{j};
        pval = varargin{j+1};
        k = strmatch(lower(pname), okargs);
        if isempty(k)
            error('stats:hmmgenerate:BadParameter',...
                  'Unknown parameter name:  %s.',pname);
        elseif length(k)>1
            error('stats:hmmgenerate:BadParameter',...
                  'Ambiguous parameter name:  %s.',pname);
        else
            switch(k)
                case 1  % symbols
                    symbols = pval;  
                    numSymbolNames = numel(symbols);
                    if length(symbols) ~= numSymbolNames
                        error('stats:hmmgenerate:BadSymbols',...
                              'SYMBOLS must be a vector.');
                    end
                    if numSymbolNames ~= numEmissions
                        error('stats:hmmgenerate:BadSymbols',...
                          'Number of Symbols must match number of emissions.');
                    end     
                    customSymbols = true;
                case 2  % statenames
                    statenames = pval;
                    numStateNames = length(statenames);
                    if numStateNames ~= numStates
                        error('stats:hmmgenerate:InputSizeMismatch',...
                      'Number of Statenames must match the number of states.');
                    end
                    customStatenames = true;
            end
        end
    end
end

% create two random sequences, one for state changes, one for emission
statechange = rand(1,L);
randvals = rand(1,L);

% calculate cumulative probabilities
trc = cumsum(tr,2);
ec = cumsum(e,2);

% normalize these just in case they don't sum to 1.
trc = trc./repmat(trc(:,end),1,numStates);
ec = ec./repmat(ec(:,end),1,numEmissions);

% Assume that we start in state 1.
currentstate = 1;

% main loop 
for count = 1:L
    % calculate state transition
    stateVal = statechange(count);
    state = 1;
    for innerState = numStates-1:-1:1
        if stateVal > trc(currentstate,innerState)
            state = innerState + 1;
            break;
        end
    end
    % calculate emission
    val = randvals(count);
    emit = 1;
    for inner = numEmissions-1:-1:1
        if val  > ec(state,inner)
            emit = inner + 1;
            break
        end
    end
    % add values and states to output
    seq(count) = emit;
    states(count) = state;
    currentstate = state;
end

% deal with names/symbols
if customSymbols
    seq = reshape(symbols(seq),1,L);
end
if customStatenames
    states = reshape(statenames(states),1,L);
end

