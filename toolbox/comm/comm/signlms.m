function alg = signlms(stepSize, algType);
%SIGNLMS   Construct a signed LMS adaptive algorithm object.
%   ALG = SIGNLMS(STEPSIZE) constructs an adaptive algorithm object based
%   on the signed least mean square (LMS) algorithm with a step size of
%   STEPSIZE.  
%   
%   ALG = SIGNLMS(STEPSIZE, ALGTYPE) constructs an adaptive algorithm
%   object of type ALGTYPE from the family of signed LMS algorithms:
%
%     ALGTYPE                   Type of Signed LMS Algorithm
%     ======================================================
%     'Sign LMS'              - Sign LMS
%     'Signed Regressor LMS'  - Signed Regressor LMS
%     'Sign Sign LMS'         - Sign-Sign LMS
%
%   Properties of the signed LMS algorithm object:
%      AlgType:       Type of signed LMS algorithm (string from above list)
%      StepSize:      Step size
%      LeakageFactor: Leakage factor (default 1)
%
%   To access or set the properties of the object ALG, use the syntax
%   ALG.Prop, where 'Prop' is the property name (for example, ALG.StepSize
%   = 0.1).  To view all properties of an object ALG, type ALG.  To
%   equalize using ALG, use LINEAREQ or DFE, followed by EQUALIZE.
%
%   See also LMS, NORMLMS, VARLMS, RLS, CMA, LINEAREQ, DFE, EQUALIZE.

%   Copyright 1996-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.6 $  $Date: 2004/04/12 23:01:24 $

% This function is a wrapper for an object constructor (adaptalg.signlms)

error(nargchk(1, 2, nargin));
if nargin==1
    algType = 'Sign LMS';
end
alg = adaptalg.signlms(stepSize, algType);

