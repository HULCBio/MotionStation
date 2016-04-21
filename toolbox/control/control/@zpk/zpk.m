function sys = zpk(varargin)
%ZPK  Create zero-pole-gain models or convert to zero-pole-gain format.
%
%  Creation:
%    SYS = ZPK(Z,P,K) creates a continuous-time zero-pole-gain (ZPK) 
%    model SYS with zeros Z, poles P, and gains K.  The output SYS is 
%    a ZPK object.  
%
%    SYS = ZPK(Z,P,K,Ts) creates a discrete-time ZPK model with sample
%    time Ts (set Ts=-1 if the sample time is undetermined).
%
%    S = ZPK('s') specifies H(s) = s (Laplace variable).
%    Z = ZPK('z',TS) specifies H(z) = z with sample time TS.
%    You can then specify ZPK models directly as rational expressions in 
%    S or Z, e.g.,
%       z = zpk('z',0.1);  H = (z+.1)*(z+.2)/(z^2+.6*z+.09)
%
%    SYS = ZPK creates an empty zero-pole-gain model.
%    SYS = ZPK(D) specifies a static gain matrix D.
%
%    In all syntax above, the input list can be followed by pairs
%       'PropertyName1', PropertyValue1, ...
%    that set the various properties of ZPK models (type LTIPROPS for 
%    details).  To make SYS inherit all its LTI properties from an 
%    existing LTI model REFSYS, use the syntax SYS = ZPK(Z,P,K,REFSYS).
%
%  Data format:
%    For SISO models, Z and P are the vectors of zeros and poles (set  
%    Z=[] if no zeros) and K is the scalar gain.
%
%    For MIMO systems with NY outputs and NU inputs, 
%      * Z and P are NY-by-NU cell arrays where Z{i,j} and P{i,j}  
%        specify the zeros and poles of the transfer function from
%        input j to output i
%      * K is the 2D matrix of gains for each I/O channel.  
%    For example,
%       H = ZPK( {[];[2 3]} , {1;[0 -1]} , [-5;1] )
%    specifies the two-output, one-input ZPK model
%       [    -5 /(s-1)      ]
%       [ (s-2)(s-3)/s(s+1) ] 
%
%  Arrays of zero-pole-gain models:
%    You can create arrays of ZPK models by using ND cell arrays for Z,P 
%    above, and an ND array for K.  For example, if Z,P,K are 3D arrays 
%    of size [NY NU 5], then 
%       SYS = ZPK(Z,P,K) 
%    creates the 5-by-1 array of ZPK models
%       SYS(:,:,m) = ZPK(Z(:,:,m),P(:,:,m),K(:,:,m)),   m=1:5.
%    Each of these models has NY outputs and NU inputs.
%
%    To pre-allocate an array of zero ZPK models with NY outputs and NU 
%    inputs, use the syntax
%       SYS = ZPK(ZEROS([NY NU k1 k2...])) .
%
%  Conversion:
%    SYS = ZPK(SYS) converts an arbitrary LTI model SYS to the ZPK 
%    representation. The result is a ZPK object.  
%
%    SYS = ZPK(SYS,'inv') uses a fast algorithm for conversion from state
%    space to ZPK, but is typically less accurate for high-order systems.
%
%  See also LTIMODELS, SET, GET, ZPKDATA, SUBSREF, SUBSASGN, LTIPROPS, TF, SS.

%   Author(s): A. Potvin, P. Gahinet
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.24 $  $Date: 2002/04/10 06:11:30 $

ni = nargin;
if ni & isa(varargin{1},'zpk'),
  % ZPK(SYS) where SYS is a ZPK object or a child of ZPK: leave it untouched
  sys = varargin{1};
  if ni>1,
     error('Use SET to modify the properties of ZPK objects.');
  end
  return
end

% Define default property values
inferiorto('ss')
superiorto('tf','double')
%added 'DisplayFormat','roots'
sys = struct('z',{{}},'p',{{}},'k',[],'Variable',[],'DisplayFormat',{''});


% Trap the syntax ZPK('s',...) or ZPK('z',...)
if ni & ischar(varargin{1}) & any(strcmp(varargin{1},{'s' 'p' 'z'})),
   varargin = [{0 [] 1} varargin(2:ni) {'Variable'} varargin(1)];
   ni = ni+4;
end

% Dissect the input list
DoubleInputs = 0;
LtiInput = 0;
PVstart = 0;
while DoubleInputs < ni & PVstart==0,
  nextarg = varargin{DoubleInputs+1};
  if isa(nextarg,'lti')
     LtiInput = DoubleInputs+1; 
     PVstart = DoubleInputs+2;
  elseif isstr(nextarg) | (~isempty(nextarg) & iscellstr(nextarg)),
     PVstart = DoubleInputs+1;  
  else
     DoubleInputs = DoubleInputs+1;
  end
end


% Handle bad calls
if PVstart==1,
  if ni==1,
    % Bad conversion
    error('Conversion from string to zpk is not possible.')
  else
    error('First input must contain only numerical data');
  end
elseif DoubleInputs>4 | (DoubleInputs==4 & LtiInput),
  error('Too many numerical inputs');
end


% Process numerical data 
zpkchange = 0;
switch DoubleInputs,
case 0
   if ni, error('Too many LTI arguments or missing numerical data'); end
   
case 1
   % Gain matrix 
   kmat = varargin{1};
   if ~isa(kmat,'double'),
     error('Call with single input requires 2D or ND array as input (static gain).')
   end
   z = cell(size(kmat));
   z(:) = {zeros(0,1)};
   sys.z = z;
   sys.p = z;
   sys.k = kmat;
   
case 2
   error('Missing input K');
   
otherwise
   % Z,P,K specified
   sys.z = varargin{1};    
   sys.p = varargin{2};
   sys.k = varargin{3};
   zpkchange = 3;

end


% Check consistency of NUM,DEN
if ni>0
   try 
      sys = zpkcheck(sys,zpkchange);
   catch
      rethrow(lasterror)
   end
end

% Create LTI parent
Ny = size(sys.k,1);
Nu = size(sys.k,2);
if LtiInput,
   L = varargin{LtiInput};
   if isa(L,'zpk'),
      L = L.lti;
   end   
   Ts = getst(L);
elseif DoubleInputs<=3,
   % Default parent LTI with Ts = 0
   L = lti(Ny,Nu);
   Ts = 0;
else
   % Discrete TF 
   Ts = varargin{4};
   if isempty(Ts),  
      Ts = -1;  
   elseif ~isreal(Ts) | ~isfinite(Ts) | length(Ts)~=1,
      error('Sample time T must be a real number.');
   elseif Ts<0 & Ts~=-1,
      error('Negative sample time not allowed (except Ts = -1 to mean unspecified).');
   end
   L = lti(Ny,Nu,Ts);
end

% Variable
if Ts==0,
   sys.Variable = 's';
else
   sys.Variable = 'z'; 
end
%display
sys.DisplayFormat='roots';
% ZPK is a subclass of LTI
sys = class(sys,'zpk',L);

% Issue warning if system is complex
if ~isreal(sys)
    warning('Not all complex roots come in conjugate pairs (transfer function has complex coefficients).')
end

% Finally, set any PV pairs
if (PVstart>0) & (PVstart<=ni),
   try
      set(sys,varargin{PVstart:ni})
   catch
      rethrow(lasterror)
   end
end
