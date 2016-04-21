function TFsys = tf(varargin)
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
%    You can then specify transfer functions as rational expressions in 
%    S or Z, e.g.,
%       s = tf('s');  H = (s+1)/(s^2+3*s+1)
%
%    SYS = TF creates an empty TF object.
%    SYS = TF(M) specifies a static gain matrix M.
%
%    In all syntax above, the input list can be followed by pairs
%       'PropertyName1', PropertyValue1, ...
%    that set the various properties of TF models (see LTIPROPS for details).  
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

%       Author(s): A. Potvin, 3-1-94
%       Copyright 1986-2002 The MathWorks, Inc. 
%       $Revision: 1.20 $  $Date: 2002/05/11 17:33:09 $

% Effect on other properties
% Keep all LTI parent fields

sys = varargin{1};

% Handle syntax TF(num,den,sys) with sys of class ZPK
if ~isa(sys,'zpk'),   
  nlti = 0;
  for i=1:length(varargin),
     if isa(varargin{i},'lti'), 
        nlti = nlti + 1;   ilti = i;
     end
  end

  if nlti>1, 
     error('TF cannot be called with several LTI arguments');
  else
     % Replace sys by sys.lti and call constructor tf/tf.m
     varargin{ilti} = varargin{ilti}.lti;
     TFsys = tf(varargin{:});
     return
  end
end

% Error checking
if nargin>1,
   error('Conversion from ZPK to TF: too many input arguments.');
end

% Extract data
sizes = size(sys.k);
if any(sizes==0),
   % Empty system
   TFsys = tf(cell(sizes),cell(sizes),sys.lti);
else
   num = cell(sizes);
   den = cell(sizes);
   for ct=1:prod(sizes),
      if isnan(sys.k(ct))
         num{ct} = NaN;
         den{ct} = 1;
      else
         % Zeros are roots of numerator
         ni = sys.k(ct) * poly(sys.z{ct});
         % Poles are the roots of denominator
         di = poly(sys.p{ct});
         % Make num/den of equal length
         lgap = length(di) - length(ni);
         num{ct} = [zeros(1,lgap) ni];
         den{ct} = [zeros(1,-lgap) di];
         % Check for overflow
         if ~all(isfinite(num{ct})) | ~all(isfinite(den{ct}))
            error('Overflow in conversion to transfer function (TF) form.')
         end
      end
   end % for ct
   
   % Construct TF model (turn off warning for complex data)
   lwarn = lastwarn;warn = warning('off'); 
   TFsys = tf(num,den,sys.lti);
   warning(warn);lastwarn(lwarn);
   
   % Set variable
   ch = sys.Variable;
   if ~any(strcmp(ch,{'s','z'})),
      set(TFsys,'Variable',ch);
   end
end
