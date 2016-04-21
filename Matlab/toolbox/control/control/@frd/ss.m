function SSsys = ss(varargin)
%SS  Create state-space model or convert LTI model to state space.
%       
%  Creation:
%    SYS = SS(A,B,C,D) creates a continuous-time state-space (SS) model 
%    SYS with matrices A,B,C,D.  The output SYS is a SS object.  You 
%    can set D=0 to mean the zero matrix of appropriate dimensions.
%
%    SYS = SS(A,B,C,D,Ts) creates a discrete-time SS model with sample 
%    time Ts (set Ts=-1 if the sample time is undetermined).
%
%    SYS = SS creates an empty SS object.
%    SYS = SS(D) specifies a static gain matrix D.
%
%    In all syntax above, the input list can be followed by pairs
%       'PropertyName1', PropertyValue1, ...
%    that set the various properties of SS models (type LTIPROPS for 
%    details).  To make SYS inherit all its LTI properties from an  
%    existing LTI model REFSYS, use the syntax SYS = SS(A,B,C,D,REFSYS).
%
%  Arrays of state-space models:
%    You can create arrays of state-space models by using ND arrays for
%    A,B,C,D above.  The first two dimensions of A,B,C,D determine the 
%    number of states, inputs, and outputs, while the remaining 
%    dimensions specify the array sizes.  For example, if A,B,C,D are  
%    4D arrays and their last two dimensions have lengths 2 and 5, then 
%       SYS = SS(A,B,C,D)
%    creates the 2-by-5 array of SS models 
%       SYS(:,:,k,m) = SS(A(:,:,k,m),...,D(:,:,k,m)),  k=1:2,  m=1:5.
%    All models in the resulting SS array share the same number of 
%    outputs, inputs, and states.
%
%    SYS = SS(ZEROS([NY NU S1...Sk])) pre-allocates space for an SS array 
%    with NY outputs, NU inputs, and array sizes [S1...Sk].
%
%  Conversion:
%    SYS = SS(SYS) converts an arbitrary LTI model SYS to state space,
%    i.e., computes a state-space realization of SYS.
%
%    SYS = SS(SYS,'min') computes a minimal realization of SYS.
%
%  See also LTIMODELS, DSS, RSS, DRSS, SSDATA, LTIPROPS, TF, ZPK, FRD.

% Note:
%      SYS_SS = SS(SYS,METHOD)  allows users to supply their own 
%      state-space realization algorithm via the string METHOD.
%      For instance,
%           SS(sys,'myway')
%      executes
%           [a,b,c,d] = myway(sys.num,sys.den)
%      to perform the conversion to state space.  User-specified functions 
%      should follow this syntax.


%      Author(s): P. Gahinet, S. Almy
%      Copyright 1986-2002 The MathWorks, Inc. 
%      $Revision: 1.9 $  $Date: 2002/04/10 06:16:40 $

% Effect on other properties: keep all LTI parent fields

if isa(varargin{1},'frd')
   % Error out of SS(FRD) case
   error('Unable to convert FRD model to SS format.');
else
   % Handle syntax ss(a,b,c,d,sys) with sys of class FRD
   nlti = 0;
   for i=1:length(varargin),
      if isa(varargin{i},'lti')
         nlti = nlti + 1;   ilti = i;
      end
   end
   
   if nlti>1
      error('Cannot call SS with several LTI arguments.');
   else
      % Replace sys by sys.lti and call constructor ss/ss.m
      varargin{ilti} = varargin{ilti}.lti;
      SSsys = ss(varargin{:});
   end
end
