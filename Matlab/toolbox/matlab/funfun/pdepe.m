function sol = pdepe(m,pde,ic,bc,xmesh,t,options,varargin)
%PDEPE  Solve initial-boundary value problems for parabolic-elliptic PDEs in 1-D.
%   SOL = PDEPE(M,PDEFUN,ICFUN,BCFUN,XMESH,TSPAN) solves initial-boundary
%   value problems for small systems of parabolic and elliptic PDEs in one
%   space variable x and time t to modest accuracy. There are npde unknown
%   solution components that satisfy a system of npde equations of the form   
%
%   c(x,t,u,Du/Dx) * Du/Dt = x^(-m) * D(x^m * f(x,t,u,Du/Dx))/Dx + s(x,t,u,Du/Dx)
% 
%   Here f(x,t,u,Du/Dx) is a flux and s(x,t,u,Du/Dx) is a source term. m must
%   be 0, 1, or 2, corresponding to slab, cylindrical, or spherical symmetry,
%   respectively. The coupling of the partial derivatives with respect to
%   time is restricted to multiplication by a diagonal matrix c(x,t,u,Du/Dx). 
%   The diagonal elements of c are either identically zero or positive. 
%   An entry that is identically zero corresponds to an elliptic equation and 
%   otherwise to a parabolic equation. There must be at least one parabolic 
%   equation. An entry of c corresponding to a parabolic equation is permitted 
%   to vanish at isolated values of x provided they are included in the mesh
%   XMESH, and in particular, is always allowed to vanish at the ends of the
%   interval. The PDEs hold for t0 <= t <= tf and a <= x <= b. The interval
%   [a,b] must be finite. If m > 0, it is required that 0 <= a. The solution
%   components are to have known values at the initial time t = t0, the
%   initial conditions. The solution components are to satisfy boundary
%   conditions at x=a and x=b for all t of the form   
% 
%       p(x,t,u) + q(x,t) * f(x,t,u,Du/Dx) = 0 
%
%   q(x,t) is a diagonal matrix. The diagonal elements of q must be either
%   identically zero or never zero. Note that the boundary conditions are
%   expressed in terms of the flux rather than Du/Dx. Also, of the two
%   coefficients, only p can depend on u.      
%
%   The input argument M defines the symmetry of the problem.
%
%   [C,F,S] = PDEFUN(X,T,U,DUDX) is a function that evaluates the quantities
%   defining the differential equation. The input arguments are scalars X and
%   T and vectors U and DUDX that approximate the solution and its partial
%   derivative with respect to x, respectively. PDEFUN returns column vectors
%   C (containing the diagonal of the matrix c(x,t,u,Dx/Du)), F, and S
%   (representing the flux and source term, respectively).
%
%   U = ICFUN(X) is a function that evaluates the initial conditions. When
%   called with a scalar argument X, ICFUN evaluates and returns the initial
%   values of the solution components at X in the column vector U.  
%
%   [PL,QL,PR,QR] = BCFUN(XL,UL,XR,UR,T) is a function that evaluates the
%   components of the boundary conditions at time T. PL and QL are column vectors
%   corresponding to p and the diagonal of q, evaluated at the left boundary,
%   similarly PR and QR correspond to the right boundary. When m > 0 and a = 0, 
%   boundedness of the solution near x = 0 requires that the flux f vanish at
%   a = 0. PDEPE imposes this boundary condition automatically.  
%
%   PDEPE returns values of the solution on a mesh provided as the input
%   array XMESH. The entries of XMESH must satisfy 
%       a = XMESH(1) < XMESH(2) < ... < XMESH(NX) = b 
%   for some NX >= 3. Discontinuities in c and/or s due to material
%   interfaces are permitted if the problem requires the flux f to be
%   continuous at the interfaces and a mesh point is placed at each
%   interface. The ODEs resulting from discretization in space are integrated
%   to obtain approximate solutions at times specified in the input array
%   TSPAN. The entries of TSPAN must satisfy 
%       t0 = TSPAN(1) < TSPAN(2) < ... < TSPAN(NT) = tf 
%   for some NT >= 3. The arrays XMESH and TSPAN do not play the same roles
%   in PDEPE: The time integration is done with an ODE solver that selects
%   both the time step and formula dynamically. The cost depends weakly on
%   the length of TSPAN. Second order approximations to the solution are made
%   on the mesh specified in XMESH. Generally it is best to use closely
%   spaced points where the solution changes rapidly. PDEPE does not select
%   the mesh in x automatically like it does in t; you must choose an
%   appropriate fixed mesh yourself. The discretization takes into account
%   the coordinate singularity at x = 0 when m > 0, so it is not necessary to
%   use a fine mesh near x = 0 for this reason. The cost depends strongly on
%   the length of XMESH.   
%  
%   The solution is returned as a multidimensional array SOL. UI = SOL(:,:,i)
%   is an approximation to component i of the solution vector u for 
%   i = 1:npde. The entry UI(j,k) = SOL(j,k,i) approximates UI at 
%   (t,x) = (TSPAN(j),XMESH(k)). 
%
%   SOL = PDEPE(M,PDEFUN,ICFUN,BCFUN,XMESH,TSPAN,OPTIONS) solves as above
%   with default integration parameters replaced by values in OPTIONS, an
%   argument created with the ODESET function. Only some of the options of
%   the underlying ODE solver are available in PDEPE - RelTol, AbsTol,
%   NormControl, InitialStep, and MaxStep. See ODESET for details.    
%
%   SOL = PDEPE(M,PDEFUN,ICFUN,BCFUN,XMESH,TSPAN,OPTIONS,P1,P2...) passes the
%   additional parameters P1, P2,... to the functions PDEFUN, ICFUN, and
%   BCFUN. Use OPTIONS = [] as a place holder if no options are set.   
%
%   If UI = SOL(j,:,i) approximates component i of the solution at time TSPAN(j) 
%   and mesh points XMESH, PDEVAL evaluates the approximation and its partial
%   derivative Dui/Dx at the array of points XOUT and returns them in UOUT
%   and DUOUTDX: 
%      [UOUT,DUOUTDX] = PDEVAL(M,XMESH,UI,XOUT)
%   NOTE that the partial derivative Dui/Dx is evaluated here rather than the
%   flux. The flux is continuous, but at a material interface the partial
%   derivative may have a jump. 
%  
%   Example
%         x = linspace(0,1,20);
%         t = [0 0.5 1 1.5 2];
%         sol = pdepe(0,@pdex1pde,@pdex1ic,@pdex1bc,x,t);         
%     solve the problem defined by the function pdex1pde with the initial and
%     boundary conditions provided by the functions pdex1ic and pdex1bc,
%     respectively. The solution is obtained on a spatial mesh of 20 equally
%     spaced points in [0 1] and it is returned at times t = [0 0.5 1 1.5 2].  
%     Often a good way to study a solution is plot it as a surface and use 
%     Rotate 3D. The first unknown, u1, is extracted from sol and plotted with
%         u1 = sol(:,:,1);
%         surf(x,t,u1);
%     PDEX1 shows how this problem can be coded using subfunctions. For more
%     examples see PDEX2, PDEX3, PDEX4, PDEX5.  The examples can be read 
%     separately, but read in order they form a mini-tutorial on using PDEPE. 
%
%   See also PDEVAL, ODE15S, ODESET, ODEGET, @.

%   The spatial discretization used is that of R.D. Skeel and M. Berzins, A
%   method for the spatial discretization of parabolic equations in one space
%   variable, SIAM J. Sci. Stat. Comput., 11 (1990) 1-32. The time
%   integration is done with ODE15S. PDEPE exploits the capabilities this
%   code has for solving the differential-algebraic equations that arise when
%   there are elliptic equations and for handling Jacobians with specified
%   sparsity pattern.

%   Elliptic equations give rise to algebraic equations after discretization. 
%   Initial values taken from the given initial conditions may not be 
%   "consistent" with the discretization, so PDEPE may have to adjust these 
%   values slightly before beginning the time integration. For this reason 
%   the values output for these components at t0 may have a discretization 
%   error comparable to that at any other time. No adjustment is necessary 
%   for solution components corresponding to parabolic equations. If the mesh 
%   is sufficiently fine, the program will be able to find consistent initial 
%   values close to the given ones, so if it has difficulty initializing, 
%   try refining the mesh. 

%   Lawrence F. Shampine and Jacek Kierzenka
%   Copyright 1984-2003 The MathWorks, Inc. 
%   $Revision: 1.8.4.2 $  $Date: 2003/10/21 11:55:49 $

% check input parameters
if nargin < 6 
  error('MATLAB:pdepe:NotEnoughInputs', 'Not enough input arguments.')
end

switch m
case {0, 1, 2}
otherwise
  error('MATLAB:pdepe:InvalidM', 'm must be one of 0,1,2.')
end
  
t = t(:);
nt = length(t);
if nt < 3
  error('MATLAB:pdepe:TSPANnotEnoughPts', 'TSPAN must have at least 3 entries.')
end
if any(diff(t) <= 0)
  error('MATLAB:pdepe:TSPANnotIncreasing',...
        'The entries of TSPAN must be strictly increasing.')
end

xmesh = xmesh(:);
if m > 0 && xmesh(1) < 0
  error('MATLAB:pdepe:NegXMESHwithPosM',...
        'When M > 0, XMESH(1) must be non-negative.')
end
nx = length(xmesh);
if nx < 3
  error('MATLAB:pdepe:XMESHnotEnoughPts', 'XMESH must have at least 3 entries.')
end
h = diff(xmesh);
if any(h <= 0)
  error('MATLAB:pdepe:XMESHnotIncreasing',...
        'The entries of XMESH must be strictly increasing.')
end

% Initialize the nx-1 points xi where functions will be evaluated 
% and as many coefficients in the difference formulas as possible. 
xi = zeros(nx-1,1);
zeta = zeros(nx-1,1);
midpoint = xmesh(1:end-1) + 0.5 * h;
singular = (xmesh(1) == 0 & m > 0);
switch m
case 0      
  xi = midpoint;
  zeta = xi;
case 1
  if singular
    xi(1) = h(1) * (2/3);
    zeta(1) = 0;
  else
    xi(1) = h(1) / log(xmesh(2) / xmesh(1));
    zeta(1) = sqrt(xi(1) * midpoint(1));
  end
  for i = 2:nx-1
    xi(i) = h(i) / log(xmesh(i+1) / xmesh(i));
    zeta(i) = sqrt(xi(i) * midpoint(i));
  end
case 2
  if singular
    xi(1) = h(1) * (2/3);
    zeta(1) = 0;
  else
    xi(1) = xmesh(1) * xmesh(2) * log(xmesh(2) / xmesh(1)) / h(1);
    zeta(1) = (xmesh(1) * xmesh(2) * midpoint(1))^(1/3);
  end
  for i = 2:nx-1
    xi(i) = xmesh(i) * xmesh(i+1) * log(xmesh(i+1) / xmesh(i)) / h(i);
    zeta(i) = (xmesh(i) * xmesh(i+1) * midpoint(i))^(1/3);
  end
end
xim = xi .^ m;
zxmp1 = zeros(nx-1,1);
xzmp1 = zeros(nx,1);
zxmp1(1) = zeta(1)^(m+1) - xmesh(1)^(m+1);
for i = 2:nx-1
  zxmp1(i) = zeta(i)^(m+1) - xmesh(i)^(m+1);
  xzmp1(i) = xmesh(i)^(m+1) - zeta(i-1)^(m+1);
end
xzmp1(nx) = xmesh(nx)^(m+1) - zeta(nx-1)^(m+1);
zxmp1 = zxmp1 / (m+1);
xzmp1 = xzmp1 / (m+1);

% Form the initial values with a column of unknowns at each 
% mesh point and then reshape into a column vector for dae. 
temp = feval(ic,xmesh(1),varargin{:});
npde = length(temp);
y0 = zeros(npde,nx);
y0(:,1) = temp;
for j = 2:nx
  y0(:,j) = feval(ic,xmesh(j),varargin{:});
end

% Classify the equations so that a constant, diagonal mass matrix 
% can be formed. The entries of c are to be identically zero or
% vanish only at the entries of xmesh, so need be checked only at one 
% point not in the mesh.
D = ones(npde,nx);
zerovec = zeros(1,nx-2);

[U,Ux] = pdentrp(m,xmesh(1),y0(:,1),xmesh(2),y0(:,2),xi(1));
c = feval(pde,xi(1),t(1),U,Ux,varargin{:});
for j = 1:npde
  if c(j) == 0
    D(j,2:nx-1) = zerovec;
  end
end

[pL,qL,pR,qR] = feval(bc,xmesh(1),y0(:,1),xmesh(nx),y0(:,nx),t(1),varargin{:});
if ~singular
  for j = 1:npde
    if qL(j) == 0    
      D(j,1) = 0;
    end
  end
end
for j = 1:npde
  if qR(j) == 0    
    D(j,nx) = 0;
  end
end
M = sparse(diag(D(:)));

y0 = y0(:);
ny = length(y0);

S = sparse(ny,ny);
S(1:npde,1:2*npde) = ones(npde,2*npde);
row = npde + 1;
col = 1;
for i = 2:nx-1
  S(row:row-1+npde,col:col-1+3*npde) = ones(npde,3*npde);
  row = row + npde;
  col = col + npde;
end
S(row:end,col:end) = ones(npde,2*npde);

if nargin < 7
  oldopts = [];
else
  reltol = odeget(options,'RelTol');
  abstol = odeget(options,'AbsTol');
  normcontrol = odeget(options,'NormControl');
  initialstep = odeget(options,'InitialStep');
  maxstep = odeget(options,'MaxStep');
  oldopts = odeset('RelTol',reltol,'AbsTol',abstol,'NormControl',normcontrol,...
                   'InitialStep',initialstep,'MaxStep',maxstep);
end
opts = odeset(oldopts,'Mass',M,'JPattern',S);           

[t,y] = ode15s(@pdeodes,t,y0,opts,pde,ic,bc,m,xmesh,xi,xim,zxmp1,xzmp1,varargin{:});
           
sol = zeros(nt,nx,npde);
for i=1:npde
  sol(:,:,i) = y(:,i:npde:end);
end

% --------------------------------------------------------------------------

function dudt = pdeodes(tnow,y,pde,ic,bc,m,x,xi,xim,zxmp1,xzmp1,varargin)
%PDEODES  Assemble the difference equations and evaluate the time derivative
%   for the ODE system. 
   
nx = length(x);
npde = length(y) / nx;
u = reshape(y,npde,nx);
up = zeros(npde,nx);
[U,Ux] = pdentrp(m,x(1),u(:,1),x(2),u(:,2),xi(1));
[cL,fL,sL] = feval(pde,xi(1),tnow,U,Ux,varargin{:});

%  Evaluate the boundary conditions
[pL,qL,pR,qR] = feval(bc,x(1),u(:,1),x(nx),u(:,nx),tnow,varargin{:});

%  Left boundary
if x(1) == 0 && m > 0   %  Singular
  for j = 1:npde
    up(j,1) = sL(j) + (m+1) * fL(j) / xi(1);
    if cL(j) ~= 0
      up(j,1) = up(j,1) / cL(j);
    end
  end
else
  for j = 1:npde
    if qL(j) == 0
      up(j,1) = pL(j);
    else
      up(j,1) = pL(j) + (qL(j) / x(1)^m) * ...
               (xim(1) * fL(j) + zxmp1(1) * sL(j));
      denom = (qL(j) / x(1)^m) * zxmp1(1) * cL(j);
      if denom ~= 0
        up(j,1) = up(j,1) / denom;
      end
    end
  end
end
%  Interior points
for i = 2:nx-1
  [U,Ux] = pdentrp(m,x(i),u(:,i),x(i+1),u(:,i+1),xi(i));
  [cR,fR,sR] = feval(pde,xi(i),tnow,U,Ux,varargin{:});  
  
  for j = 1:npde
    up(j,i) = (xim(i) * fR(j) - xim(i-1) * fL(j)) + ...
              (zxmp1(i) * sR(j) + xzmp1(i) * sL(j));
    denom = zxmp1(i) * cR(j) + xzmp1(i) * cL(j);
    if denom ~= 0
      up(j,i) = up(j,i) / denom;
    end
  end
  cL = cR;
  fL = fR;
  sL = sR;
end
%  Right boundary
for j = 1:npde
  if qR(j) == 0
    up(j,nx) = pR(j);
  else
    up(j,nx) = pR(j) + (qR(j) / x(nx)^m) * ...
              (xim(nx-1) * fL(j) - xzmp1(nx) * sL(j));
    denom = -(qR(j) / x(nx)^m) * xzmp1(nx) * cL(j);
    if denom ~= 0
      up(j,nx) = up(j,nx) / denom;
    end
  end
end
dudt = up(:);
  
