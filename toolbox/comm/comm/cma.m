function alg = cma(stepSize, varargin);
%CMA   Construct a constant modulus algorithm (CMA) object.
%   ALG = CMA(STEPSIZE) constructs an adaptive algorithm object based on
%   the constant modulus algorithm (CMA) with a step size of STEPSIZE.  
%
%   ALG = CMA(STEPSIZE, LEAKAGEFACTOR) sets the leakage factor.  
%   LEAKAGEFACTOR must be in the range 0 to 1.  A value of 1 corresponds to
%   a conventional weight update algorithm, and a value of 0 corresponds to
%   a memoryless update algorithm.
%
%   Properties of the CMA algorithm object:
%      AlgType:       'Constant Modulus' 
%      StepSize:      Step size
%      LeakageFactor: Leakage factor (default 1)
%
%   To access or set the properties of the object ALG, use the syntax
%   ALG.Prop, where 'Prop' is the property name (for example, ALG.StepSize
%   = 0.1).  To view all properties of an object ALG, type ALG.  To
%   equalize using ALG, use LINEAREQ or DFE, followed by EQUALIZE.
%
%   See also LMS, SIGNLMS, NORMLMS, VARLMS, RLS, LINEAREQ, DFE, EQUALIZE.

%   Copyright 1996-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2003/09/01 09:11:39 $

% This function is a wrapper for an object constructor (adaptalg.cma)

error(nargchk(1, 2, nargin));
alg = adaptalg.cma(stepSize, varargin{:});
