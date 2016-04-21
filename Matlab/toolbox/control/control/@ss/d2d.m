function sys = d2d(sys,Ts,Nd)
%D2D  Resample discrete LTI system.
%
%   SYS = D2D(SYS,TS) resamples the discrete-time LTI model SYS 
%   to produce an equivalent discrete system with sample time TS.
%
%   See also D2C, C2D, LTIMODELS.

%	Andrew C. W. Grace 2-20-91, P. Gahinet 8-28-96
%	Copyright 1986-2002 The MathWorks, Inc. 
%	$Revision: 1.27 $  $Date: 2002/04/10 06:02:03 $

ni = nargin;
error(nargchk(2,3,ni));

% Trap 4.0 syntax D2D(SYS,[],Nd) where Nd = input delays
if ni==3,
   if any(abs(Nd-round(Nd))>1e3*eps*abs(Nd)),
      error('Last argument ND must be a vector of integers.')
   elseif ~isequal(size(Nd),[1 1]) & length(Nd)~=size(sys,2),
      error('Length of ND must match number of inputs.')
   end
   set(sys,'inputdelay',round(Nd));
   % Call DELAY2Z
   sys = delay2z(sys);
   return
end

% Dimensions
sizes = size(sys.d);
ny = sizes(1);
nu = sizes(2);
nsys = prod(sizes(3:end));
Ts0 = getst(sys);

% Keep track of state dimension
Nx0 = size(sys,'order');
if length(Nx0)==1,
   Nx0 = Nx0(ones(1,nsys),1);
else
   Nx0 = Nx0(:);
end
Nx = Nx0;

% Error checking
if isstatic(sys),
   % Static gain
   set(sys,'ts',Ts);   
   return
elseif ~isa(Ts,'double') | length(Ts)~=1 | Ts<=0,
    error('Sample time TS must be a positive scalar')
elseif Ts0==0,
   error('Input system SYS must be discrete.')
elseif Ts0<0,
   % Unspecified sample time
   error('Sample time of input system SYS is unspecified (Ts=-1).')
elseif hasdelay(sys),
   % REVISIT: add code for the case where Ts/Ts0 is integer (see true
   % feasibility test below)
   error('Not supported for delay systems.')
end

% Sample time ratio
rTs = Ts/Ts0;
if abs(round(rTs)-rTs)<sqrt(eps)*rTs,
   rTs = round(rTs);
elseif hasdelay(sys),
   error('Cannot resample delay systems when TS is not a multiple of SYS.Ts.')
end

% Loop over each model
lwarn = lastwarn;warn = warning('off');
for k=1:nsys,
   % Get data for k-th model
   sysk = subsref(sys,substruct('()',{':' ':' k}));
   [a,b,c,d] = ssdata(sysk);
   RealFlag = isreal(a) & isreal(b) & isreal(c);
   
   % Look for real negative poles
   p = eig(a);
   if any(imag(p)==0 & real(p)<=0) & rem(rTs,1),
      % Negative real poles with fractional resampling: let D2C handle it
      try
         [sys.a{k},sys.b{k},sys.c{k},sys.d(:,:,k)] = ssdata(c2d(d2c(sysk),Ts));
      catch
         rethrow(lasterror)
      end
      Nx(k) = size(sys.a{k},1);
   else
      % Proceed directly
      % REVISIT: need dedicated code for delay case
      nx = size(a,1);
      if rTs==round(rTs),
         M = [a b;zeros(nu,nx) eye(nu)]^rTs;
      else
         M = expm(rTs*logm([a b;zeros(nu,nx) eye(nu)]));
      end
      if RealFlag
          M = real(M);
      end
      sys.a{k} = M(1:nx,1:nx);
      sys.b{k} = M(1:nx,nx+1:nx+nu);
   end
end
warning(warn);lastwarn(lwarn);

% Check state dimensions
if any(Nx>Nx0),
   warning('Model order was increased to handle real negative poles.')
   sys.StateName(end+1:max(Nx),1) = {''};
end

% Reset sample time
set(sys,'ts',Ts);
