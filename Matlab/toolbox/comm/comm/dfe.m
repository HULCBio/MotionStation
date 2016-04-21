function eqobj = dfe(nFwdWeights, nFbkWeights, alg, varargin);
%DFE   Construct a decision feedback equalizer object.
%   EQOBJ = DFE(NFWDWEIGHTS, NFBKWEIGHTS, ALG) constructs a decision
%   feedback equalizer. The equalizer's feedforward and feedback filters
%   have NFWDWEIGHTS and NFBKWEIGHTS symbol-spaced complex weights,
%   respectively.  ALG is an adaptive algorithm object which can be
%   constructed from any of the following functions: LMS, SIGNLMS, NORMLMS,
%   VARLMS, RLS, CMA.  The equalizer weights are initialized with zero 
%   values.
%
%   EQOBJ = DFE(NFWDWEIGHTS, NFBKWEIGHTS, ALG, SIGCONST) sets the signal
%   constellation vector of the desired output.  The default vector is  
%   [-1 1], which corresponds to binary phase shift keying (BPSK).
%
%   EQOBJ = DFE(NFWDWEIGHTS, NFBKWEIGHTS, ALG, SIGCONST, NSAMP) constructs
%   a DFE with a fractionally-spaced forward filter.  The forward filter
%   has NFWDWEIGHTS complex weights spaced at T/NSAMP, where T is the
%   symbol period and NSAMP is a positive integer.  Note that NSAMP=1
%   corresponds to a symbol-spaced forward filter.
%
%   The DFE object has the following properties:
%                   EqType: 'Decision Feedback Equalizer'
%                 nWeights: Number of feedforward/feedback filter weights;
%                           specified as two-element row vector: 
%                           [NFWDWEIGHTS NFBKWEIGHTS]
%              nSampPerSym: Number of samples per symbol
%                   RefTap: Reference tap index (from 1 to NFWDWEIGHTS)
%                 SigConst: Signal constellation
%                  Weights: Complex coefficient vector
%             WeightInputs: Tap weight input vector
%     ResetBeforeFiltering: Resets equalizer state every call (0 or 1)
%      NumSamplesProcessed: Number of samples processed
%     *** Plus adaptive-algorithm-specific properties ***
%
%   To access or set the properties of the object EQOBJ, use the syntax
%   EQOBJ.Prop, where 'Prop' is the property name (for example,
%   EQOBJ.nWeights = [8 4]).  To view all properties of an object ALG, type
%   ALG.   To equalize using EQOBJ, use EQUALIZE.
%
%   The Weights vector is the concatenation of the forward filter and
%   feedback filter weight vectors.  Similarly, the WeightInputs vector is
%   the concatenation of the forward filter and feedback filter tap weight
%   input vectors. To initialize or reset EQOBJ, use the syntax
%   RESET(EQOBJ).  You can also set the reference tap index, which
%   effectively delays the reference signal with respect to the input
%   signal (see EQUALIZE).
%
%   See also LMS, SIGNLMS, NORMLMS, VARLMS, RLS, CMA, LINEAREQ, EQUALIZE.

%   Copyright 1996-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2004/01/26 23:19:24 $

% This function is a wrapper for an object constructor (equalizer.dfe)

error(nargchk(3, 5, nargin));
eqobj = equalizer.dfe(nFwdWeights, nFbkWeights, alg, varargin{:});
