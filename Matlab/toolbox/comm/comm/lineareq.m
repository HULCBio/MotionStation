function eqobj = lineareq(nWeights, alg, varargin);
%LINEAREQ   Construct a linear equalizer object.
%   EQOBJ = LINEAREQ(NWEIGHTS, ALG) constructs a symbol-spaced linear
%   equalizer object.  The equalizer has NWEIGHTS complex weights.  ALG is
%   an adaptive algorithm object, which you can construct using any of the
%   following functions: LMS, SIGNLMS, NORMLMS, VARLMS, RLS, CMA.  The 
%   equalizer weights are initialized with zero values.
%
%   EQOBJ = LINEAREQ(NWEIGHTS, ALG, SIGCONST) sets the signal constellation
%   vector of the desired output.  The default vector is [-1 1], which
%   corresponds to binary phase shift keying (BPSK).
%
%   EQOBJ = LINEAREQ(NWEIGHTS, ALG, SIGCONST, NSAMP) constructs a
%   fractionally-spaced linear equalizer object.  The equalizer has
%   NWEIGHTS complex weights spaced at T/NSAMP, where T is the symbol
%   period and NSAMP is a positive integer. Note that NSAMP=1 corresponds
%   to a symbol-spaced equalizer.
%
%   The linear equalizer object has the following properties:
%                   EqType: 'Linear Equalizer' 
%                 nWeights: Number of weights 
%              nSampPerSym: Number of input samples per symbol (equal to NSAMP)
%                   RefTap: Reference tap index (between 1 and nWeights)
%                 SigConst: Signal constellation
%                  Weights: Complex coefficient vector 
%             WeightInputs: Tap weight input vector
%     ResetBeforeFiltering: Resets equalizer state every call (0 or 1)
%      NumSamplesProcessed: Number of samples processed
%     *** Plus adaptive-algorithm-specific properties ***
% 
%   To access or set the properties of the object EQOBJ, use the syntax
%   EQOBJ.Prop, where 'Prop' is the property name (for example,
%   EQOBJ.nWeights = 8).  To view all properties of an object ALG, type
%   ALG.  To equalize using EQOBJ, use EQUALIZE.
%
%   To initialize or reset EQOBJ, use the syntax RESET(EQOBJ).  You can
%   also set the reference tap index, which effectively delays the
%   reference signal with respect to the input signal (see EQUALIZE).
%
%   See also LMS, SIGNLMS, NORMLMS, VARLMS, RLS, CMA, DFE, EQUALIZE.

%   Copyright 1996-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2004/01/26 23:19:26 $

% This function is a wrapper for an object constructor (equalizer.lineareq)

error(nargchk(2, 4, nargin));
eqobj = equalizer.lineareq(nWeights, alg, varargin{:});
