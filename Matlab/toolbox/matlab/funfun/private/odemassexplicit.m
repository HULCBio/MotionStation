function [odeFcn,odeArgs] = odemassexplicit( FcnHandlesUsed,massType,odeFcn,...
                                odeArgs,massFcn,massArgs,massL,massU)  
%ODEMASSEXPLICIT  Helper function for handling the mass matrix
%   For explicit ODE solvers -- incorporate the mass matrix into the ODE
%   function.   
%
%   See also ODE113, ODE23, ODE45.

%   Jacek Kierzenka
%   Copyright 1984-2003 The MathWorks, Inc.
%   $Revision: 1.5.4.2 $  $Date: 2004/04/16 22:06:48 $

if FcnHandlesUsed
  switch massType
   case 1  % LU factors of M available
    odeArgs = [{odeFcn,massL,massU},odeArgs];    
    odeFcn = @ExplicitSolverHandleMass1;
   case 2
    odeArgs = [{odeFcn,massFcn},odeArgs];    
    odeFcn = @ExplicitSolverHandleMass2;
   otherwise % case {3,4}
    odeArgs = [{odeFcn,massFcn},odeArgs];    
    odeFcn = @ExplicitSolverHandleMass34;
  end
else % ode-file:  F(t,y,'mass',p1,p2...)    
  if massType == 1   % LU factors of M available
    odeArgs = [{odeFcn,massL,massU},odeArgs];    
    odeFcn = @ExplicitSolverHandleMass1;   
  else  
    odeArgs = [{odeFcn},odeArgs];  
    odeFcn = @ExplicitSolverHandleMassOld;   
  end
end

% --------------------------------------------------------------------------

function yp = ExplicitSolverHandleMass1(t,y,odeFcn,L,U,varargin)
  yp = U \ (L \ feval(odeFcn,t,y,varargin{:}));
  
% --------------------------------------------------------------------------
  
function yp = ExplicitSolverHandleMass2(t,y,odeFcn,massFcn,varargin)
  yp = feval(massFcn,t,varargin{:}) \ feval(odeFcn,t,y,varargin{:});
  
% --------------------------------------------------------------------------  

function yp = ExplicitSolverHandleMass34(t,y,odeFcn,massFcn,varargin)
  yp = feval(massFcn,t,y,varargin{:}) \ feval(odeFcn,t,y,varargin{:});

% --------------------------------------------------------------------------  
  
function yp = ExplicitSolverHandleMassOld(t,y,odeFcn,varargin)
  yp = feval(odeFcn,t,y,'mass',varargin{2:end}) \ ...
       feval(odeFcn,t,y,varargin{:});
  
