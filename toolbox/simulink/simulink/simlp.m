function [x,lambda,how]=simlp(f,A,B,vlb,vub,x,neqcstr,verbosity)
%SIMLP Helper function for GETXO; solves linear programming problem.
%   X=SIMLP(f,A,b) solves the linear programming problem:
%
%            min f'x    subject to:   Ax <= b
%             x
%
%   X=SIMLP(f,A,b,VLB,VUB) defines a set of lower and upper bounds on the 
%   design variables, X, so that the solution is always in the range 
%   VLB <= X <= VUB.
%
%   X=SIMLP(f,A,b,VLB,VUB,X0) sets the initial starting point to X0.
%
%   X=SIMLP(f,A,b,VLB,VUB,X0,N) indicates that the first N constraints defined
%   by A and b are equality constraints.
%
%   X=SIMLP(f,A,b,VLB,VUB,X0,N,DISPLAY) controls the level of warning
%   messages displayed.  Warning messages can be turned off with
%   DISPLAY = -1.
%
%   [x,LAMBDA]=SIMLP(f,A,b) returns the set of Lagrangian multipliers,
%   LAMBDA, at the solution.
%
%   [X,LAMBDA,HOW] = SIMLP(f,A,b) also returns a string how that indicates
%   error conditions at the final iteration.
%
%   SIMLP produces warning messages when the solution is either unbounded
%   or infeasible.
%
%   SIMLP calls private/QPSUB.
%
%   See also GETX0.

%   Copyright 1990-2002 The MathWorks, Inc.
%   $Revision: 1.7 $
%   Andy Grace 7-9-90.

if nargin<8, verbosity = 0;
  if nargin<7, neqcstr=0;
    if nargin<6, x=[];
      if nargin<5, vub=[];
        if nargin<4, vlb=[];
        end
      end
    end
  end
end
[ncstr,nvars]=size(A);
nvars = max([length(f),nvars]); % In case A is empty

if isempty(x), x=zeros(nvars,1); end

%% V5 update:
if isempty(A), A=zeros(0,nvars); end
if isempty(B), B=zeros(0,1); end

caller = 'lp';
negdef = 0; normalize = 1;
[x,lambda,how]=qpsub([],f(:),A,B(:),vlb,vub, ...
    x(:),neqcstr,verbosity,caller,ncstr,nvars,negdef,normalize);
