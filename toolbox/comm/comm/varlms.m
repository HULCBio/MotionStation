function alg = varlms(initStep, incStep, minStep, maxStep);
%VARLMS   Construct a variable step size LMS adaptive algorithm object.
%   ALG = VARLMS(INITSTEP, INCSTEP, MINSTEP, MAXSTEP) constructs an
%   adaptive algorithm object based on the variable step size least mean
%   square (LMS) algorithm.  INITSTEP is the initial value of the step size
%   parameter.  INCSTEP is the increment by which the step size changes
%   from iteration to iteration.  MINSTEP and MAXSTEP are the limits
%   between which the step size can vary.
%
%   The variable step size LMS algorithm object has the following
%   properties:
%      AlgType:       'Variable Step Size LMS'
%      LeakageFactor: Leakage factor (default 1)
%      InitStep:      Initial value of step size
%      IncStep:       Increment for step size
%      MinStep:       Minimum value of step size
%      MaxStep:       Maximum value of step size
%
%   When the variable step size LMS algorithm object is used to construct
%   an equalizer object, the equalizer object inherits the algorithm
%   object's properties. In addition, the equalizer object includes the
%   property StepSize, which is a vector of step size values, one for each
%   equalizer weight.  The vector is initialized to zeros(1,N), where N is
%   the total number of equalizer weights.
%
%   To access or set the properties of the object ALG, use the syntax
%   ALG.Prop, where 'Prop' is the property name (for example, ALG.InitStep
%   = 0.1).  To view all properties of an object ALG, type ALG.  To
%   equalize using ALG, use LINEAREQ or DFE, followed by EQUALIZE.
%
%   See also LMS, SIGNLMS, NORMLMS, RLS, CMA, LINEAREQ, DFE, EQUALIZE.

%   Copyright 1996-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2004/01/26 23:19:30 $

% This function is a wrapper for an object constructor (adaptalg.varlms)

error(nargchk(4, 4, nargin));
alg = adaptalg.varlms(initStep, incStep, minStep, maxStep);
