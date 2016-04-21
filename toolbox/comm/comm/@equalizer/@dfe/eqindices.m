function [i1, nn1, nn2, id] = eqindices(eq);
% Set indices for input buffer, u, and decision sample, d.
% - i1 is the input buffer index for the current input signal sample:
%      u(i1)=sample
% - nn1 and nn2 are input buffer indices used to perform the 
%   sample shifting operation each equalizer iteration: 
%      u(nn2)=u(nn1)
% - id is an "index" into the decision value (d is a scalar): 
%      decision_feedback_value=d(id); id=[] for a linear equalizer; id=1 for DFE.

% Copyright 2003 The MathWorks, Inc.

nFwdWeights = eq.nWeights(1);
nFbkWeights = eq.nWeights(2);
nSampPerSym = eq.nSampPerSym;

nWeights = nFwdWeights + nFbkWeights;

% Indices for feedforward section.
iff1 = 1:nSampPerSym;
nnff1 = 1:(nFwdWeights-nSampPerSym);
nnff2 = nnff1 + nSampPerSym;

if nFbkWeights>0

    % Indices for feedback section.
    ifb1 = nFwdWeights+1;
    nnfb1 = ifb1:nWeights-1;
    nnfb2 = nnfb1 + 1;

    % Index value for decision sample.
    id = 1;

else

    % Set all feedback indices to empty matrices.
    % The DFE will behave like a linear equalizer.
    
    ifb1 = [];
    nnfb1 = [];
    nnfb2 = [];
    
    id = [];

end

% Resultant indices for both sections.
i1 = [iff1 ifb1];
nn1 = [nnff1 nnfb1];
nn2 = [nnff2 nnfb2];
