function ZPKsys = zpk(varargin)
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
%    You can then specify ZPK models as rational expressions in 
%    S or Z, e.g.,
%       z = zpk('z',0.1);  H = (z+.1)*(z+.2)/(z^2+.6*z+.09)
%
%    SYS = ZPK creates an empty zero-pole-gain model.
%    SYS = ZPK(D) specifies a static gain matrix D.
%
%    In all syntax above, the input list can be followed by pairs
%       'PropertyName1', PropertyValue1, ...
%    that set the various properties of ZPK models (see LTIPROPS for 
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
%  See also LTIMODELS, SET, GET, ZPKDATA, SUBSREF, SUBSASGN, LTIPROPS, TF, SS.

% Note:
%      SYSOUT = ZPK(SYS,method)  allows users to supply their own conversion 
%      algorithm METHOD.  For instance,
%            zpk(sys,'myway')
%      executes
%            [z,p,k] = myway(sys.a,sys.b,sys.c,sys.d,sys.e)
%      to perform the conversion to ZPK.  User-specified functions 
%      should follow this syntax.

%       Author(s): A. Potvin, 3-1-94, P. Gahinet, 4-5-96
%       Copyright 1986-2002 The MathWorks, Inc. 
%       $Revision: 1.27.4.1 $  $Date: 2002/11/11 22:22:08 $

% Effect on other properties
% Keep all LTI parent fields
sys = varargin{1};

% Handle syntax zpk(z,p,k,sys) with sys of class SS
if ~isa(sys,'ss'),  
  nlti = 0;
  for i=1:length(varargin),
     if isa(varargin{i},'lti'), 
        nlti = nlti + 1;   ilti = i;
     end
  end

  if nlti>1, 
     error('Cannot call ZPK with several LTI arguments.');
  else
     % Replace sys by sys.lti and call constructor zpk/zpk.m
     varargin{ilti} = varargin{ilti}.lti;
     ZPKsys = zpk(varargin{:});
     return
  end
end


% Error checking
ni = nargin;
if ni>2,
   error('Conversion from SS to ZPK: too many input arguments.');
elseif ni==2 & ~isstr(varargin{2}),
   error('Conversion from SS to ZPK: second argument must be a string.');
elseif ni==1
   method = 'tzero';
else
   method = varargin{2};
end

% Check for simple cases
sizes = size(sys.d);
ny = sizes(1);
nu = sizes(2);
if any(sizes==0),
   % Empty system
   ZPKsys = zpk(cell(sizes),cell(sizes),zeros(sizes),sys.lti);
   return
elseif ~any(strcmp(method,{'inv','tzero'})),
   % User-specified conversion method
   [z,p,k] = feval(method,sys.a,sys.b,sys.c,sys.d,sys.e);
   ZPKsys = zpk(z,p,k,sys.lti);
   return
end


% Conversion starts
Zeros = cell(sizes);
Poles = cell(sizes);
Gain = zeros(sizes);
for k=1:prod(sizes(3:end)),
   ak = sys.a{k};
   bk = sys.b{k};
   ck = sys.c{k};
   ek = sys.e{k};
   nx = size(ak,1);
   FullPoles = zeros(0,1);
   
   % Compute each entry of the transfer function
   for l=1:ny*nu,
      j = 1+floor((l-1)/ny);
      i = 1+rem(l-1,ny);
      
      % Eliminate structurally nonminimal dynamics in sys(i,j,k)
      [ar,br,cr,er] = smreal(ak,bk(:,j),ck(i,:),ek);
      
      % Compute the zeros
      % REVISIT : update tzero (GETZER in tests/lti more accurate) + 
      %           make it handle descriptor [z,k] = tzero(a,b,c,d,e);
      % Use GETZEROS (TZERO) to compute the roots of the numerator of sys(i,j)
      [Zeros{i,j,k},Gain(i,j,k)] = getzeros(ar,br,cr,sys.d(i,j,k),er);
      
      % Compute the poles
      if Gain(i,j,k)==0,
         Poles{i,j,k} = zeros(0,1);
      elseif size(ar,1)<nx
         Poles{i,j,k} = getpoles(ar,er);
      else
         if isempty(FullPoles) && nx>0
            FullPoles = getpoles(ak,ek); % computed only once
         end
         Poles{i,j,k} = FullPoles;
      end
      
   end
end

lwarn = lastwarn;warn = warning('off');
ZPKsys = zpk(Zeros,Poles,Gain,sys.lti);
warning(warn);lastwarn(lwarn);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function p = getpoles(ar,er)
%GETPOLES  Computes poles
if isempty(er)
    p = eig(ar);
else
    p = eig(ar,er);
end