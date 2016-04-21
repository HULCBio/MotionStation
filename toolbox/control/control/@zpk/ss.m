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

%   Author(s): P. Gahinet, 5-1-96
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.28.4.1 $  $Date: 2002/11/11 22:22:18 $

sys = varargin{1};

% Handle syntax ss(a,b,c,d,sys) with sys of class ZPK
if ~isa(sys,'zpk'),   
  nlti = 0;
  for i=1:length(varargin),
     if isa(varargin{i},'lti'), 
        nlti = nlti + 1;   ilti = i;
     end
  end

  if nlti>1, 
     error('SS cannot be called with several LTI arguments');
  else
     % Replace sys by sys.lti and call constructor ss/ss.m
     varargin{ilti} = varargin{ilti}.lti;
     SSsys = ss(varargin{:});
     return
  end
end

% Error checking
ni = nargin;
if ni>2,
   error('Conversion from ZPK to SS: too many input arguments.');
elseif ~isproper(sys),
   error('Improper system: conversion to state space not possible');
elseif ni==2 & ~isstr(varargin{2}),
   error('Conversion from ZPK to SS: second argument must be a string.');
end

% Quick exit in simple cases
sizes = size(sys.k);
if any(sizes==0),
   % Empty system
   SSsys = ss([],[],[],zeros(sizes),mindelay(sys.lti));  
   return
end

% Compute model order information
[ro,co] = zpkorder(sys.z,sys.p,sys.k);
Ny = sizes(1);
Nu = sizes(2);

% Preallocate state matrices
ArraySizes = [sizes(3:end) 1 1];
a = cell(ArraySizes);
b = cell(ArraySizes);
c = cell(ArraySizes);
d = zeros(sizes);

% Loop over each model
for m=1:prod(ArraySizes),
   if co(m)<=ro(m),
      % Realize each column and concatenate realizations
      am = [];  bm = [];  cm = zeros(Ny,0);  dm = zeros(Ny,0);
      for j=1:Nu,
         [aj,bj,cj,dj] = sioreal(sys.z(:,j,m),sys.p(:,j,m),sys.k(:,j,m));
         [am,bm,cm,dm] = ssops('hcat',am,bm,cm,dm,[],aj,bj,cj,dj,[]);
      end
   else
      % Realize each row and concatenate realizations
      am = [];  bm = zeros(0,Nu);  cm = [];  dm = zeros(0,Nu);
      for i=1:Ny,
         [ai,bi,ci,di] = sioreal(sys.z(i,:,m),sys.p(i,:,m),sys.k(i,:,m));
         [am,bm,cm,dm] = ssops('vcat',am,bm,cm,dm,[],ai,bi,ci,di,[]);
      end
   end
   
   % Balance resulting state-space realization
   % RE: Perform I/O scaling to guarantee invariance under sys->t*sys
   [am,bm,cm] = abcbalance(am,bm,cm,[],Inf,'noperm','scale');
   
   % Store model #m
   a{m} = am;
   b{m} = bm;
   c{m} = cm;
   d(:,:,m) = dm;
end

% Create state-space model and balance it
% Note: For models with I/O delays, minimize number of I/O delays 
%       and of input vs output delays
lwarn = lastwarn;warn = warning('off');
SSsys = ss(a,b,c,d,mindelay(sys.lti));
warning(warn);lastwarn(lwarn);

% Compute minimal realization if needed
if ni==2 & strncmpi(varargin{2},'min',min(3,length(varargin{2}))),
   for m=1:prod(sizes(3:end)),
      SSsys(:,:,m) = minreal(SSsys(:,:,m),[],0);
   end
end



