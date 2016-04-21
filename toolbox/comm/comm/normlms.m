function alg = normlms(stepSize, varargin);
%NORMLMS   Construct a normalized LMS adaptive algorithm object.
%   ALG = NORMLMS(STEPSIZE) constructs an adaptive algorithm object based
%   on the normalized least mean square (LMS) algorithm with a step size of
%   STEPSIZE.
%
%   ALG = NORMLMS(STEPSIZE, BIAS) sets the bias parameter of the normalized
%   LMS algorithm.  This parameter is used to overcome difficulties when
%   the algorithm's input signal is small.  The default bias value is zero.
%
%   The normalized LMS algorithm object has the following properties:
%      AlgType:       'Normalized LMS'
%      StepSize:      Step size
%      LeakageFactor: Leakage factor (default 1)
%      Bias:          Bias parameter
%
%   To access or set the properties of the object ALG, use the syntax
%   ALG.Prop, where 'Prop' is the property name (for example, ALG.StepSize
%   = 0.1).  To view all properties of an object ALG, type ALG.  To
%   equalize using ALG, use LINEAREQ or DFE, followed by EQUALIZE.
%
%   See also LMS, SIGNLMS, VARLMS, RLS, CMA, LINEAREQ, DFE, EQUALIZE.

%   Copyright 1996-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2003/09/01 09:11:46 $

% This function is a wrapper for an object constructor
% (adaptalg.normlms)

error(nargchk(1, 2, nargin));
alg = adaptalg.normlms(stepSize, varargin{:});
