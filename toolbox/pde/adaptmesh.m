function [u,p,e,t]=adaptmesh(g,b,c,a,f,p1,p2,p3,p4,p5,p6,p7,p8,p9,p10,p11,p12,p13,p14,p15,p16,p17,p18,p19,p20,p21,p22,p23,p24)
%ADAPTMESH Adaptive mesh generation and PDE solution.
%
%       [U,P,E,T]=ADAPTMESH(G,B,C,A,F,P1,V1,...) performs adaptive mesh
%       generation and PDE solution.  The large number of possible input
%       option is handled using property-value pair arguments.  The first
%       five arguments G, B, C, A, and F are not optional.
%
%       The function produces a solution U to the elliptic scalar PDE problem
%       -div(c*grad(u))+a*u=f where the problem geometry and boundary
%       conditions given by G and B.
%
%       The solution u is represented as the MATLAB column vector U.
%       See ASSEMPDE for details.
%
%       G describes the geometry of the PDE problem. G can
%       either be a Decomposed Geometry Matrix or the name of Geometry
%       M-file. See either DECSG or PDEGEOM for details.
%
%       B describes the boundary conditions of the PDE problem.  B
%       can either be a Boundary Condition Matrix or the name of Boundary
%       M-file. See PDEBOUND for details.
%
%       The adapted triangular mesh of the PDE problem is given by the triangle
%       data P, E, and T.  See either INITMESH or PDEGEOM for details.
%
%       The coefficients C, A and F of the PDE problem can
%       be given in a wide variety of ways.  See ASSEMPDE for details.
%
%       Valid property/value pairs include
%
%       Prop.   Value/{Default}         Description
%       ----------------------------------------------------------------------
%       Maxt    Positive integer {Inf}  Maximum number of new triangles
%       Ngen    Positive integer {10}   Maximum number of triangle generations
%       Mesh    P1, E1, T1              Initial mesh
%       Tripick {pdeadworst}|pdeadgsc   Triangle selection method
%       Par     Numeric {0.5}           Function parameter
%       Rmethod {longest}|regular       Triangle refinement method
%       Nonlin  on | off                Use nonlinear solver
%       Toln    numeric {1e-3}          Nonlinear tolerance
%       Init    string|numeric          Nonlinear initial solution value
%       Jac     {fixed}|lumped|full     Nonlinear solver Jacobian calculation
%       Norm    Numeric {Inf}           Nonlinear solver residual norm
%
%       Par is passed to the tripick function. Normally it is used as
%       tolerance of how well the solution fits the equation. No more than
%       Ngen successive refinements are attempted. Refinement is also
%       stopped when the number of triangles in the mesh exceeds the
%       Maxt.
%
%       P1, E1, and T1 are the input mesh data. This triangle mesh is used
%       as a starting mesh for the adaptive algorithm. If no initial mesh
%       is provided, the result of a call to INITMESH with no options is
%       used as initial mesh.
%
%       The triangle pick method is a user-definable triangle selection
%       method.  Given the error estimate computed by the function PDEJMPS,
%       the triangle pick method selects the triangles to be refined
%       in the next triangle generation. The function is called using the
%       arguments P, T, CC, AA, FF, U, ERRF, and PAR.  P and T represent the
%       current generation of triangles, CC, AA, FF are the current
%       coefficients for the PDE problem, expanded to triangle midpoints,
%       U is the current solution, ERRF is the computed error estimate,
%       and PAR, the function parameter, given to ADAPTMESH as optional
%       argument. The matrices CC, AA, FF, and ERRF all have NT columns,
%       where NT is the current number of triangles.
%       The number of rows in CC, AA, and FF are exactly the same as the
%       input arguments C, A, and F. ERRF has one row for each equation
%       in the system. There are two standard triangle selection methods
%       in the PDE Toolbox - PDEADWORST and PDEADGSC.
%       PDEADWORST selects triangles where ERRF exceeds a fraction
%       (default: 0.5) of the worst value. PDEADGSC selects triangles
%       using a relative tolerance criterion.
%
%       The refinement method is either 'longest' or 'regular'.
%       See REFINEMESH for details.
%
%       Also nonlinear PDE problems can be solved by the adaptive algorithms.
%       For nonlinear PDE problems, the 'Nonlin' parameter must be set
%       to 'on'. The nonlinear tolerance Toln and nonlinear initial value
%       U0 are passed to the nonlinear solver. See PDENONLIN for details.
%
%       See also ASSEMPDE, PDEBOUND, PDEGEOM, INITMESH, REFINEMESH, PDENONLIN

%       A. Nordmark 10-18-94, AN 01-23-95, MR 05-24-95.
%       Copyright 1994-2003 The MathWorks, Inc.
%       $Revision: 1.9.4.1 $  $Date: 2003/10/21 12:25:57 $

alfa=0.15;
beta=0.15;
mexp=1;
mesh=0;
nonl=0;
gotu=0;

% Default values
Tripick='pdeadworst';
Rmethod='longest';
Toln=1e-4;
Ngen=10;
Maxt=Inf;
Par=0.5;
Jac='fixed';
norm=Inf;

k=1;
noptarg=nargin-5;
while k<=noptarg
  Name=eval(['p' int2str(k)]);
  if ~ischar(Name)
    error('PDE:adaptmesh:ParamNotString', 'Parameter must be a string.')
  elseif size(Name,1)~=1,
    error('PDE:adaptmesh:ParamNumRowsOrEmpty', 'Parameter must be a non-empty single row string.')
  end
  Name=lower(Name);
  if strcmp(Name,'mesh')
    if noptarg-k<3
      error('PDE:adaptmesh:MeshNumValues', 'Option ''mesh'' must have three values.')
    end
    k=k+1;
    p=eval(['p' int2str(k)]);
    k=k+1;
    e=eval(['p' int2str(k)]);
    k=k+1;
    t=eval(['p' int2str(k)]);
    if ischar(p) || ischar(e) || ischar(t)
      error('PDE:adaptmesh:MeshNotNumeric', 'Mesh data must be numeric.');
    end
    mesh=1;
  elseif strcmp(Name,'tripick')
    if noptarg-k<1
      error('PDE:adaptmesh:TripickNoValue', 'Option ''tripick'' must have a value.')
    end
    k=k+1;
    Tripick=eval(['p' int2str(k)]);
    if ~ischar(Tripick)
      error('PDE:adaptmesh:TripickNotString', 'Tripick value must be a string.')
    end
  elseif strcmp(Name,'rmethod')
    if noptarg-k<1
      error('PDE:adaptmesh:RmethodNoValue', 'Option ''rmethod'' must have a value.')
    end
    k=k+1;
    Rmethod=eval(['p' int2str(k)]);
    if ~ischar(Rmethod)
      error('PDE:adaptmesh:RmethodNotString', 'Rmethod value must be a string.')
    end
  elseif strcmp(Name,'toln')
    if noptarg-k<1
      error('PDE:adaptmesh:TolnNoValue', 'Option ''toln'' must have a value.')
    end
    k=k+1;
    Toln=eval(['p' int2str(k)]);
    if ischar(Toln)
      error('PDE:adaptmesh:TolnNotNumeric', 'Toln value must be numeric.')
    end
  elseif strcmp(Name,'ngen')
    if noptarg-k<1
      error('PDE:adaptmesh:NgenNoValue', 'Option ''ngen'' must have a value.')
    end
    k=k+1;
    Ngen=eval(['p' int2str(k)]);
    if ischar(Ngen)
      error('PDE:adaptmesh:NgenNotNumeric', 'Ngen value must be numeric.')
    end
  elseif strcmp(Name,'maxt')
    if noptarg-k<1
      error('PDE:adaptmesh:MaxtNoValue', 'Option ''maxt'' must have a value.')
    end
    k=k+1;
    Maxt=eval(['p' int2str(k)]);
    if ischar(Maxt)
      error('PDE:adaptmesh:MaxtNotNumeric', 'Maxt value must be numeric.')
    end
  elseif strcmp(Name,'par')
    if noptarg-k<1
      error('PDE:adaptmesh:ParNoValue', 'Option ''par'' must have a value.')
    end
    k=k+1;
    Par=eval(['p' int2str(k)]);
    if ischar(Par)
      error('PDE:adaptmesh:ParNotNumeric', 'Par value must be numeric.')
    end
  elseif strcmp(Name,'nonlin')
    if noptarg-k<1
      error('PDE:adaptmesh:NonlinNoValue', 'Option ''nonlin'' must have a value.')
    end
    k=k+1;
    Nonlin=eval(['p' int2str(k)]);
    if ~ischar(Nonlin)
      error('PDE:adaptmesh:NonlinNotString', 'Nonlin value must be a string.')
    end
    Nonlin=lower(Nonlin);
    if strcmp(Nonlin,'on')
      nonl=1;
    elseif ~strcmp(Nonlin,'off')
      error('PDE:adaptmesh:NonlinInvalidString', 'Nonlin value must be off | {on} .')
    end
  elseif strcmp(Name,'init')
    if noptarg-k<1
      error('PDE:adaptmesh:InitNoValue', 'Option ''init'' must have a value.')
    end
    k=k+1;
    u=eval(['p' int2str(k)]);
    gotu=1;
  elseif strcmp(Name,'jac')
    if noptarg-k<1
      error('PDE:adaptmesh:JacNoValue', 'Option ''jac'' must have a value.')
    end
    k=k+1;
    Jac=eval(['p' int2str(k)]);
    if ~ischar(Jac)
      error('PDE:adaptmesh:JacNotString', 'Jac value must be a string.')
    end
    Jac=lower(deblank(Jac));
    if ~(strcmp(Jac,'fixed') || strcmp(Jac,'lumped') || strcmp(Jac,'full'))
      error('PDE:adaptmesh:JacInvalidString', 'Jac value must be {fixed} | lumped | full.')
    end
  elseif strcmp(Name,'norm')
    if noptarg-k<1
      error('PDE:adaptmesh:NormNoValue', 'Option ''norm'' must have a value.')
    end
    k=k+1;
    norm=eval(['p' int2str(k)]);
    if ischar(norm)
      error('PDE:adaptmesh:NormNotNumeric', 'Norm value must be numeric.')
    end
  else
    error('PDE:adaptmesh:InvalidOption',  ['Unknown option: ' Name])
  end
  k=k+1;
end

if ~mesh
  [p,e,t]=initmesh(g);
end
np=size(p,2);

gen=0;

while 1,

  fprintf('Number of triangles: %g\n',size(t,2))

  if nonl
    if gotu
      u=pdenonlin(b,p,e,t,c,a,f,'jacobian',Jac,'U0',u,'tol',Toln,'norm',norm);
    else
      u=pdenonlin(b,p,e,t,c,a,f,'jacobian',Jac,'tol',Toln,'norm',norm);
    end
    gotu=1;
  else
    u=assempde(b,p,e,t,c,a,f);
  end

  if any(isnan(u))
    error('PDE:adaptmesh:NaNinSolution', 'Solution contains NaNs.')
  end

  % Expand values
  [cc,aa,ff]=pdetxpd(p,t,u,c,a,f);

  errf=pdejmps(p,t,cc,aa,ff,u,alfa,beta,mexp);

  i=feval(Tripick,p,t,cc,aa,ff,u,errf,Par);

  if length(i)==0,
    fprintf('\nAdaption completed.\n')
    break;
  elseif size(t,2)>Maxt
    fprintf('\nMaximum number of triangles obtained.\n');
    break
  elseif gen>=Ngen,
    fprintf('\nMaximum number of refinement passes obtained.\n');
    break
  end

  tl=i';
% Kludge: tl must be a column vector
  if size(tl,1)==1,
    tl=[tl;tl];
  end

  u=reshape(u,np,length(u)/np);
  [p,e,t,u]=refinemesh(g,p,e,t,u,tl,Rmethod);
  u=u(:);
  np=size(p,2);
  gen=gen+1;
end


