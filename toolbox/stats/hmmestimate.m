function [tr,E] = hmmestimate(seq,states,varargin)
%HMMESTIMATE estimates the parameters for an HMM given state information.
%   [TR, E] = HMMESTIMATE(SEQ,STATES) calculates the maximum likelihood
%   estimate of the transition, TR, and emission, E, probabilities of an
%   HMM for sequence, SEQ, with known states, STATES.  
%
%   HMMESTIMATE(...,'SYMBOLS',SYMBOLS) allows you to specify the symbols
%   that are emitted. SYMBOLS can be a numeric array or a cell array of the
%   names of the symbols.  The default symbols are integers 1 through N,
%   where N is the number of possible emissions.
%
%   HMMESTIMATE(...,'STATENAMES',STATENAMES) allows you to specify the
%   names of the states. STATENAMES can be a numeric array or a cell array
%   of the names of the states. The default statenames are 1 through M,
%   where M is the number of states.
%
%   HMMESTIMATE(...,'PSEUDOEMISSIONS',PSEUDOE) allows you to specify
%   pseudocount emission values. These should be used to avoid zero
%   probability estimates for emission with very low probability that may
%   not be represented in the sample sequence. PSEUDOE should be a matrix
%   of size M x N, where M is the number of states in the HMM and N is the
%   number of possible emissions. 
%
%   HMMESTIMATE(...,'PSEUDOTRANSITIONS',PSEUDOTR) allows you to specify
%   pseudocount transition values. These should be used to avoid zero
%   probability estimates for emission with very low probability that may
%   not be represented in the sample sequence. PSEUDOTR should be a matrix
%   of size M x M, where M is the number of states in the HMM. 
%
%   If the states are not known then use HMMTRAIN to estimate the model
%   parameters. 
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
%       [seq, states] = hmmgenerate(1000,tr,e);
%       [estimateTR, estimateE] = hmmestimate(seq,states);
%
%
%   See also  HMMGENERATE, HMMDECODE, HMMVITERBI, HMMTRAIN.

%   Reference: Biological Sequence Analysis, Durbin, Eddy, Krogh, and
%   Mitchison, Cambridge University Press, 1998.  

%   Copyright 1993-2004 The MathWorks, Inc. 
%   $Revision: 1.3.4.2 $  $Date: 2003/11/01 04:26:30 $

pseudoEcounts = false;
pseudoTRcounts = false;
tr = [];
E = [];
seqLen = length(seq);
if length(states) ~= seqLen
    error('stats:hmmestimate:InputSizeMismatch',...
          'Input sequence and states must be the same length.');
end
uniqueSymbols = unique(seq);
uniqueStates = unique(states);

if isempty(uniqueSymbols) 
    warning('stats:hmmestimate:EmptySequence','The sequence is empty.');
    return
end
if isempty(uniqueStates)
    warning('stats:hmmestimate:EmptyState','The state data is empty.');
    return
end    

if isnumeric(seq)
    numSymbols = max(uniqueSymbols);
    numStates = max(uniqueStates);
else
    numSymbols = length(uniqueSymbols);
    numStates = length(uniqueStates);
end

if nargin > 2
    if rem(nargin,2) == 1
        error('stats:hmmestimate:WrongNumberArgs',...
              'Incorrect number of arguments to %s.',mfilename);
    end
    okargs = {'symbols','statenames','pseudoemissions','pseudotransitions'};
    for j=1:2:nargin-3
        pname = varargin{j};
        pval = varargin{j+1};
        k = strmatch(lower(pname), okargs);
        if isempty(k)
            error('stats:hmmestimate:BadParameter',...
                  'Unknown parameter name:  %s.',pname);
        elseif length(k)>1
            error('stats:hmmestimate:BadParameter',...
                  'Ambiguous parameter name:  %s.',pname);
        else
            switch(k)
                case 1  % symbols
                    symbols = pval;  
                    numSymbolNames = numel(symbols);
                    if length(symbols) ~= numSymbolNames
                        error('stats:hmmestimate:BadSymbols',...
                              'SYMBOLS must be a vector');
                    end
                    [dummy, seq]  = ismember(seq,symbols);
                    uniqueSymbols = unique(seq);
                    numSymbols = max([uniqueSymbols, numSymbolNames]);
                    if numSymbolNames < numSymbols 
                        error('stats:hmmestimate:BadSymbols',...
                             'There are more symbols in SEQ than in SYMBOLS.');
                    end
                case 2  % statenames
                    statenames = pval;
                    numStateNames = numel(statenames);
                    if length(statenames) ~= numStateNames
                        error('stats:hmmestimate:BadStateNames',...
                              'STATENAMES must be a vector');
                    end
                    if numStateNames < numStates
                        error('stats:hmmestimate:InputSizeMismatch',...
                      'Number of Statenames must match the number of states.');
                    end
                    [dummy, states]  = ismember(states,statenames);
                    uniqueStates = unique(states);
                    numStates = max([uniqueStates, numStateNames]);
                    
                case 3  % Pseudocount emissions
                    pseudoE = pval;
                    [rows, cols] = size(pseudoE);
                    if  rows < numStates 
                        error('stats:hmmestimate:InputSizeMismatch',...
                            'There are more states in STATES than in PSEUDO.');
                    end
                    if  cols < numSymbols 
                        error('stats:hmmestimate:InputSizeMismatch',...
                              'There are more symbols in SEQ than in PSEUDO.');
                    end
                    numStates = rows;
                    numSymbols = cols;
                    pseudoEcounts = true;
                case 4  % Pseudocount transitions
                    pseudoTR = pval;
                    [rows, cols] = size(pseudoTR);
                    if rows ~= cols
                        error('stats:hmmestimate:BadTransitions',...
                              'PSEUDOTRANSITIONS matrix must be square.');
                    end
                    if  rows < numStates 
                        error('stats:hmmestimate:InputSizeMismatch',...
                            'There are more states in STATES than in PSEUDO.');
                    end
                    numStates = rows;
                    pseudoTRcounts = true;
            end
        end
    end
end

tr = zeros(numStates);
E = zeros(numStates, numSymbols);
% count up the transitions from the state path
for count = 1:seqLen-1
    tr(states(count),states(count+1)) = tr(states(count),states(count+1)) + 1;
end
% and count up the emissions for each state
for count = 1:seqLen
    E(states(count),seq(count)) = E(states(count),seq(count)) + 1;
end

% add pseudo counts if necessart
if pseudoEcounts
    E = E + pseudoE;
end

if pseudoTRcounts
    tr = tr + pseudoTR;
end

trRowSum = sum(tr,2);
ERowSum = sum(E,2);

% if we don't have any values then report zeros instead of NaNs.
trRowSum(trRowSum == 0) = -inf;
ERowSum(ERowSum == 0) = -inf;

% normalize to give frequency estimate.
tr = tr./repmat(trRowSum,1,numStates);
E = E./repmat(ERowSum,1,numSymbols);
