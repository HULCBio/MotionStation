function sys = tf(varargin)
%TF  Creation of transfer functions or conversion to transfer function.
%
%  Creation:
%    SYS = TF(NUM,DEN) creates a continuous-time transfer function SYS with 
%    numerator(s) NUM and denominator(s) DEN.  The output SYS is a TF object.  
%
%    SYS = TF(NUM,DEN,TS) creates a discrete-time transfer function with
%    sample time TS (set TS=-1 if the sample time is undetermined).
%
%    S = TF('s') specifies the transfer function H(s) = s (Laplace variable).
%    Z = TF('z',TS) specifies H(z) = z with sample time TS.
%    You can then specify transfer functions directly as rational expressions 
%    in S or Z, e.g.,
%       s = tf('s');  H = (s+1)/(s^2+3*s+1)
%
%    SYS = TF creates an empty TF object.
%    SYS = TF(M) specifies a static gain matrix M.
%
%    In all syntax above, the input list can be followed by pairs
%       'PropertyName1', PropertyValue1, ...
%    that set the various properties of TF models (type LTIPROPS for details).  
%    To make SYS inherit all its LTI properties from an existing LTI model
%    REFSYS, use the syntax SYS = TF(NUM,DEN,REFSYS).
%
%  Data format:
%    For SISO models, NUM and DEN are row vectors listing the numerator and
%    denominator coefficients in 
%     * descending powers of s or z by default
%     * ascending powers of q = z^-1 if the 'Variable' property is set to  
%       'z^-1' or 'q' (DSP convention).
%
%    For MIMO models with NY outputs and NU inputs, NUM and DEN are NY-by-NU
%    cell arrays of row vectors where NUM{i,j} and DEN{i,j} specify the 
%    transfer function from input j to output i.  For example,
%       H = TF( {-5 ; [1 -5 6]} , {[1 -1] ; [1 1 0]})
%    specifies the two-output, one-input transfer function
%       [     -5 /(s-1)      ]
%       [ (s^2-5s+6)/(s^2+s) ] 
%
%    By default, transfer functions are displayed as functions of 's' or 'z'.
%    Alternatively, you can set the variable name to 'p' (continuous time) 
%    and 'z^-1' or 'q' (discrete time) by modifying the 'Variable' property.
%
%  Arrays of transfer functions:
%    You can create arrays of transfer functions by using ND cell arrays for
%    NUM and DEN above.  For example, if NUM and DEN are cell arrays of size
%    [NY NU 3 4], then 
%       SYS = TF(NUM,DEN) 
%    creates the 3-by-4 array of transfer functions
%       SYS(:,:,k,m) = TF(NUM(:,:,k,m),DEN(:,:,k,m)),  k=1:3,  m=1:4.
%    Each of these transfer functions has NY outputs and NU inputs.
%
%    To pre-allocate an array of zero transfer functions with NY outputs
%    and NU inputs, use the syntax
%       SYS = TF(ZEROS([NY NU k1 k2...])) .
%
%  Conversion:
%    SYS = TF(SYS) converts an arbitrary LTI model SYS to the transfer 
%    function representation. The result is a TF object.  
%
%    SYS = TF(SYS,'inv') uses a fast algorithm for conversion from state
%    space to TF, but is typically less accurate for high-order systems.
%
%  See also LTIMODELS, FILT, SET, GET, TFDATA, SUBSREF, LTIPROPS, ZPK, SS.

%   Author(s): A. Potvin, P. Gahinet
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.21 $  $Date: 2002/04/10 06:06:45 $


ni = nargin;
if ni & isa(varargin{1},'tf'),
  % TF(SYS) where SYS is a TF object or a child of TF: leave it untouched
  sys = varargin{1};
  if ni>1,
     error('Use SET to modify the properties of TF objects.');
  end
  return
end

% Define default property values
inferiorto('ss','zpk')
superiorto('double')
sys = struct('num',{{}},'den',{{}},'Variable',[]);

% Trap the syntax TF('s',...) or TF('z',...)
% RE: Do not support q=TF('q') because we can't make q+q^2 = 1/z+(1/z)^2 
%     minimal
if ni & ischar(varargin{1}) & any(strcmp(varargin{1},{'s' 'p' 'z'})),
   varargin = [{[1 0] [0 1]} varargin(2:ni) {'Variable'} varargin(1)];
   ni = ni+3;
end

% Dissect input list
DoubleInputs = 0;
LtiInput = 0;
PVstart = 0;
while DoubleInputs<ni & PVstart==0,
  nextarg = varargin{DoubleInputs+1};
  if isa(nextarg,'lti'),
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
     error('Conversion from string to tf is not possible.')
   else
     error('First input must contain only numerical data');
   end
elseif DoubleInputs>3 | (DoubleInputs==3 & LtiInput),
   error('Too many numerical inputs');
end


% Process numerical data 
ndchange = 0;
switch DoubleInputs,
case 0
   if ni, 
      error('Too many LTI arguments or missing numerical data'); 
   end
   
case 1
   % Gain matrix 
   nummat = varargin{1};
   if ~isa(nummat,'double'),
     error('Call with single input requires 2D or ND array as input (static gains).')
   end
   sys.num = cell(size(nummat));
   sys.den = cell(size(nummat));
   if ~isempty(nummat),  sys.num = num2cell(nummat);   end
   sys.den(:) = {1};
         
otherwise
   % NUM and DEN specified
   sys.num = varargin{1};    
   sys.den = varargin{2};
   ndchange = 2;
end

% Check consistency of NUM,DEN
if ni>0,
   try 
      sys = ndcheck(sys,ndchange);
   catch
      rethrow(lasterror)
   end
end

% Create LTI parent
Ny = size(sys.num,1);
Nu = size(sys.num,2);
if LtiInput,
   L = varargin{LtiInput};
   if isa(L,'tf'),
      L = L.lti;
   end
   Ts = getst(L);
elseif DoubleInputs<=2,
   % Default parent LTI with Ts = 0
   L = lti(Ny,Nu);
   Ts = 0;
else
   % Discrete TF 
   Ts = varargin{3};
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

% TF is a subclass of LTI
sys = class(sys,'tf',L);

% Issue warning if system is complex
if ~isreal(sys)
    warning('Transfer function has complex coefficients.')
end

% Set PV pairs
if (PVstart>0) & (PVstart<=ni),
   try
      set(sys,varargin{PVstart:ni})
   catch
      rethrow(lasterror)
   end
end

% Make NUM{i,j} and DEN{i,j} of equal length by padding with zero on the 
% left or right depending on sys.Variable
if ndchange,
   [sys.num,sys.den] = ndpad(sys.num,sys.den,sys.Variable);
end

