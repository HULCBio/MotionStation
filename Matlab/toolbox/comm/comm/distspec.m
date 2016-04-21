function spect = distspec(varargin)
%DISTSPEC  Compute the distance spectrum of a convolutional code.
%   SPECT = DISTSPEC(TRELLIS,N) computes the free distance and the first N
%   components of the weight and distance spectra of a linear convolutional
%   code.  The output is a structure with three elements:
%
%       SPECT.DFREE  -- the free distance of the code
%       SPECT.WEIGHT -- a length N vector that lists the total number of
%                       information bit errors in the error events
%                       enumerated in SPECT.EVENT
%       SPECT.EVENT  -- a length N vector that lists the number of error
%                       events for each distance between SPECT.DFREE and
%                       SPECT.DFREE+N-1
%
%   SPECT = DISTSPEC(TRELLIS) is the same as SPECT = DISTSPEC(TRELLIS,1)

%   Copyright 1996-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2003/08/25 05:33:44 $

%
% Check for correct number of input and output arguments
%
error(nargchk(1,2,nargin));
error(nargoutchk(0,1,nargout));

%
% Check that the first input is a valid trellis
%
if istrellis(varargin{1}),
    trellis = varargin{1};
else
    error(['The first input to DISTSPEC must be a valid trellis. ' ...
        'See ISTRELLIS for more information.']);
end

%
% If there are two input arguments, check that the second argument
% is a positive integer scalar
%
if nargin == 2,
    Nterms = varargin{2};
    if (~isscalar(Nterms) || ~isnumeric(Nterms) || ~isinteger(Nterms) || Nterms<1)
        error(['The second input to DISTSPEC must be a ' ...
            'positive integer scalar value.']);
    end
else
    Nterms = 1;
end

%
% Extract information from the trellis structure
%
global numInputs numOutputs numStates nextStates outputs maxbits weightTable distTable

numInputs = trellis.numInputSymbols;
numOutputs = trellis.numOutputSymbols;
numStates = trellis.numStates;
nextStates = trellis.nextStates+1;
outputs = oct2dec(trellis.outputs)+1;

%
% Compute information derived from the trellis structure
%
maxbits = max(max(numInputs,numOutputs),numStates);
weightTable = sum(de2bi(0:(maxbits-1))');

%
% Precompute the number of input zeros required to return the encoder to
% the all-zeros state from each state.  This is used in the tree search to
% determine the minimum adistTableitional Hamming weight that will be accumulated
% for each path, allowing the search to terminate early if the path will
% yield a distance greater than the upper limit of the specified distance
% spectrum
%
numZeros = ones(1,numStates);
for idx1 = 1:numStates,
    nlevels = 1;
    idx2 = idx1;
    while idx2>1,
        idx2 = min(nextStates(idx2,:));
        nlevels = nlevels + 1;
    end
    numZeros(idx1) = nlevels;
end

%
% Compute the distance profile.
% The distance profile indicates the minimum adistTableitional distance that
% must be adistTableed for a sequence to merge back to the all-zeros state
% and is a function of how many more levels are required to merge
%
maxMem = ceil(log(numStates)/log(2));
prevWeight = Inf*ones(1,numStates);
stateWeight = Inf*ones(1,numStates);
stateWeight(1) = 0;
for level = 2:maxMem+1,
    activeStates = find(stateWeight < Inf);
    for currStateIdx = 1:length(activeStates),
        currState = activeStates(currStateIdx);
        prevStates = find(nextStates==currState);
        for prevStateIdx = 1:length(prevStates),
            prevState = prevStates(prevStateIdx);
            pWidx = mod(prevState-1,numStates)+1;
            if prevWeight(pWidx)>(stateWeight(currState)+weightTable(outputs(prevState)))
                prevWeight(pWidx)=stateWeight(currState)+weightTable(outputs(prevState));
            end
            stateWeight = prevWeight;
        end
    end
end
d = zeros(1,maxMem+1);
for level = 1:maxMem,
    if any(numZeros==(level+1))
        d(level+1) = min(prevWeight(numZeros==level+1));
    else
        d(level+1) = d(level);
    end
end
distTable = d(numZeros(1:numStates));

%
% Step 1 - do a quick search to find dfree
%
dtest = 1;
spect.dfree=[];
while isempty(spect.dfree);
    spect = tree_search(dtest);
    dtest = dtest + 1;
end

%
% Step 2 - do an exhaustive search for the first Nterms components of the
% distance spectrum, starting with dfree
%
spect = tree_search(spect.dfree+Nterms-1);
return

%%%%%%%%%%%% end of main body of DISTSPEC function %%%%%%%%%%%%


function spect = tree_search(dMax)

global numInputs numOutputs numStates nextStates outputs maxbits weightTable distTable

spec = zeros(1,dMax+1);
bit_errors = zeros(1,dMax+1);

%
% Preallocate memory for the stack.  None of the test cases have required
% more than 1000 elements.  Allocating 10000 should be adequate.
%
state   = zeros(1,10000);
weight  = zeros(1,10000);
bitErrs = zeros(1,10000);

%
% Initialize the stack:
% Start in state 1 and adistTable a state to the stack for each input
%
topStack   = 0;
currState  = 1;
currWeight = dMax;
for input = numInputs:-1:2,
    topStack = topStack + 1;
    state(topStack)    = nextStates(currState,input);
    weight(topStack)   = currWeight - weightTable(outputs(currState,input));
    bitErrs(topStack)  = weightTable(input);
end

while(topStack>0)    
    %
    % Pop a state from the stack
    %
    currState    = state(topStack);
    currWeight   = weight(topStack);
    currBitErrs  = bitErrs(topStack);
    topStack = topStack - 1;
    
    %
    % Calculate the next states and push onto stack
    %
    for input = numInputs:-1:1,
        nextState    = nextStates(currState, input);
        nextWeight   = currWeight - weightTable(outputs(currState,input));
        nextBitErrs  = currBitErrs + weightTable(input);
        if(nextWeight >= distTable(nextState))
            if(nextState ~= 1),  % Extend path (push another state onto the stack)
                topStack = topStack + 1;
                state(topStack) = nextState;
                weight(topStack) = nextWeight;
                bitErrs(topStack) = nextBitErrs;
            else                 % Remerge at state 1, so store distance
                dMerge = dMax-nextWeight;
                if dMerge <= dMax,
                    spec(dMerge) = spec(dMerge) + 1;
                    bit_errors(dMerge) = bit_errors(dMerge) + nextBitErrs;
                end
            end
        end
    end
end

spect.dfree = min(find(spec));
spect.weight = bit_errors(spect.dfree:dMax);
spect.event = spec(spect.dfree:dMax);
return