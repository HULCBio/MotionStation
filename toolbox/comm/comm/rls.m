function alg = rls(forgetFactor, varargin);
%RLS   Construct a recursive least squares (RLS) adaptive algorithm object.
%   ALG = RLS(FORGETFACTOR) constructs an adaptive algorithm object based
%   on the recursive least squares (RLS) algorithm.  FORGETFACTOR is the
%   forgetting factor, which is between 0 and 1.  
%
%   ALG = RLS(FORGETFACTOR, INVCORRINIT) sets the initialization parameter
%   for the inverse correlation matrix (see below).  The default value is
%   0.1.
%
%   The RLS adaptive algorithm object has the following properties:
%      AlgType:       'RLS' 
%      ForgetFactor:   Forgetting factor
%      InvCorrInit:    Initialization value for inverse correlation matrix
%
%   When the RLS algorithm object is used to construct an equalizer object,
%   the equalizer object inherits the RLS algorithm object's properties. In
%   addition, the equalizer object includes the property InvCorrMatrix,
%   which is the inverse correlation matrix for the RLS algorithm.  The
%   matrix is initialized to InvCorrInit*eye(N), where N is the total
%   number of equalizer weights.
%
%   To access or set the properties of the object ALG, use the syntax
%   ALG.Prop, where 'Prop' is the property name (for example,
%   ALG.ForgetFactor = 0.95). To view all properties of an object ALG, type
%   ALG.  To equalize using ALG, use LINEAREQ or DFE, followed by EQUALIZE.
%
%   See also LMS, SIGNLMS, NORMLMS, VARLMS, CMA, LINEAREQ, DFE, EQUALIZE.

%   Copyright 1996-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2004/01/26 23:19:28 $

% This function is a wrapper for an object constructor (adaptalg.rls)

error(nargchk(1, 2, nargin));
alg = adaptalg.rls(forgetFactor, varargin{:});
