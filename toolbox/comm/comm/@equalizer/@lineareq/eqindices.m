function [i1, nn1, nn2, id] = eqindices(eq);
% Set indices for input buffer, u, and decision sample, d.
% - i1 is the input buffer index for the current input signal sample:
%      u(i1)=sample
% - nn1 and nn2 are input buffer indices used to perform the 
%   sample shifting operation each equalizer iteration: 
%      u(nn2)=u(nn1)
% - id is an "index" into the decision value (d is a scalar): 
%      decision_feedback_value=d(id); id=[] for a linear equalizer; id=1 for DFE.
%
% This method can be overloaded by subclasses.

% Copyright 2003 The MathWorks, Inc.

nWeights = eq.AdaptAlg.nWeights;
nSampPerSym = eq.nSampPerSym;

i1 = 1:nSampPerSym;
nn1 = 1:(nWeights-nSampPerSym);
nn2 = nn1 + nSampPerSym;
id = [];
