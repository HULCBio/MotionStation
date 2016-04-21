function sys = ss(varargin)
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

%   Author(s): A. Potvin, 3-94, P. Gahinet, 4-1-96
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.28.4.1 $  $Date: 2002/11/11 22:22:03 $

ni = nargin;
if ni & isa(varargin{1},'ss'),
   % Quick exit for SS(SYS) with SYS of class SS
   if ni==1
      sys = varargin{1};
   elseif ni==2 & strncmpi(varargin{2},'min',min(3,length(varargin{2}))),
      sys = minreal(varargin{1});
   else
      error('Use SET to modify the properties of SS objects.');
   end
   return
end

% Define default property values
superiorto('tf','zpk','double')
inferiorto('frd')
sys = struct('a',[],'b',[],'c',[],'d',[],'e',[],'StateName',[]);

% Dissect input list
DataInputs = 0;
LtiInput = 0;
PNVStart = 0;
while DataInputs<ni & PNVStart==0,
  nextarg = varargin{DataInputs+1};
  if isa(nextarg,'lti'),
     LtiInput = DataInputs+1;
     PNVStart = DataInputs+2;
  elseif ischar(nextarg) | iscellstr(nextarg),
     PNVStart = DataInputs+1;  
  else
     DataInputs = DataInputs+1;
  end
end

% Handle bad calls
if PNVStart==1,
   if ni==1,
     % Bad conversion
      error('Conversion from string to ss is not possible.')
   else
      error('First input must contain only numerical data.');
   end
elseif DataInputs>5 | (DataInputs==5 & LtiInput),
   error('Too many numerical inputs.');
end


% Process numerical data 
switch DataInputs,
case 0   
   if ni, 
      error('Too many LTI arguments or missing numerical data.'); 
   else
      % Empty model
      sys.a = {[]};
      sys.b = {[]};
      sys.c = {[]};
      sys.e = {[]};
   end
   
case 1
   % Gain matrix
   sys.d = varargin{1};
      
case 2
   error('Undefined C and D matrices.');
   
case 3
   error('Undefined D matrix.');
   
otherwise
   % A,B,C,D specified
   sys.a = varargin{1};
   sys.b = varargin{2};
   sys.c = varargin{3};
   sys.d = varargin{4};
end

% Check consistency
if ni
   try 
      sys = abcdechk(sys,[1 1 1 1 0]);
   catch
      rethrow(lasterror)
   end
end

% Create LTI parent
Ny = size(sys.d,1);
Nu = size(sys.d,2);
if LtiInput,
   L = varargin{LtiInput};
   if isa(L,'ss'),
      L = L.lti;
   end
elseif DataInputs<=4,
   % Default parent LTI with Ts = 0
   L = lti(Ny,Nu);
else
   % Discrete SS
   Ts = varargin{5};
   if isempty(Ts),  
      Ts = -1;  
   elseif ~isreal(Ts) | ~isfinite(Ts) | length(Ts)~=1,
      error('Sample time T must be a real number.');
   elseif Ts<0 & Ts~=-1,
      error('Negative sample time not allowed (except Ts=-1 to mean unspecified).');
   end
   L = lti(Ny,Nu,Ts);
end


% State names
EmptyStr = {''};
nx = cellfun('length',sys.a);
sys.StateName = EmptyStr(ones(max([0;nx(:)]),1),1);

% SS is a subclass of LTI
sys = class(sys,'ss',L);

% Issue warning if not real
% if ~isreal(sys)
%     warning('State-space matrices have complex entries.')
% end

% Finally, set any PV pairs
if (PNVStart>0) & (PNVStart<=ni),
   try
      set(sys,varargin{PNVStart:ni})
   catch
      rethrow(lasterror)
   end
end
