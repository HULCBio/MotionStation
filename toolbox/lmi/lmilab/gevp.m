% [tmin,xopt] = gevp(lmis,nlfc,options,t0,x0,target)
%
% Solves the generalized eigenvalue minimization problem
%
%                Minimize      t
%
% subject to the LMI constraints:
%
%             C(x)  <   0
%
%               0   <   Bj(x)           ( j=1,..,NLFC )
%
%            Aj(x)  <   t * Bj(x)       ( j=1,..,NLFC )
%
% Here x denotes the vector of (scalar) decision variables.
% The positivity constraints   Bj(x) > 0  must be specified
% for well-posedness, and the LMIs  involving  t  should be
% specified last.
%
% Input:
%  LMIS      description of the system of LMI constraints
%  NLFC      number of linear fractional constraints (LMIs
%            involving t)
%  OPTIONS   optional:  five-entry vector of control parameters.
%            The default value is used when OPTIONS(i)=0
%             OPTIONS(1): relative accuracy required on TMIN
%                         (Default = 1.0e-2)
%             OPTIONS(2): max. number of iterations (Default=100)
%             OPTIONS(3): feasibility radius R.  R>0 constrains
%                         x to   x'*x  <  R^2    (Default=1e8).
%                         R<0 means "no bound"
%             OPTIONS(4): integer value L.   The code terminates
%                         when  t  has decreased by less than
%                         OPTIONS(1) during the last L iterations
%                         (Default = 5)
%             OPTIONS(5): when nonzero, the trace of execution is
%                         turned off.
%  T0,X0     optional:  initial guesses for t,x  (ignored when
%                       unfeasible)
%  TARGET    optional:  target for TMIN.  The code terminates as
%            soon as  t  falls below this value  (DEFAULT = -1e5)
%
% Output:
%  TMIN      minimal value of t
%  XOPT      minimizing value of the vector x of decision variables
%            Use DEC2MAT to get the corresponding matrix variable
%            values.
%
%
% See also  FEASP, MINCX, DEC2MAT.

% Authors: A. Nemirovski and P. Gahinet  3/95
% Copyright 1995-2004 The MathWorks, Inc.
%       $Revision: 1.6.2.3 $

function [tmin,xopt] = gevp(LMIsys,nlfc,options,tinit,xinit,target)

if nargin<2 | nargin >6,
  error('usage: [tmin,xopt]=gevp(lmisys,nlfc{,options,tinit,xinit,target})');
elseif size(LMIsys,1)<10 | size(LMIsys,2)>1,
  error('LMIS is an incomplete LMI system description');
elseif any(LMIsys(1:8)<0),
  error('LMIS is not an LMI description');
elseif any(~LMIsys(1:3)),
  error('No matrix variable or term in this LMI sytem');
elseif nargin<3,
  options=zeros(1,5);
end

if isempty(options),
  options=zeros(1,5);
elseif length(options)~=5,
  error('OPTIONS must be a five-entry vector');
end
if nargin < 4, tinit=[]; end
if nargin < 5, xinit=[]; end
if nargin < 6, target=[]; end



% DEFAULTS for control parameters

ipin(1)=100;         % max iter
ipin(2)=5;           % # primal dichotomy steps
ipin(3)=10;          % # dual Newton steps
ipin(4)=1;           % do not use xinit
ipin(5)=~options(5); % trace of execution
ipin(6)=0;           % no protocol file
ipin(9)=2;           % RIGID BOUND on feasibility domain
ipin(10)=4;          % Cholesky -> QR
ipin(11)=1;          % No Memory Save
ipin(12)=5;          % # iterations for SLOW PROGRESS

rpin(1)=1.0e-2;      % default rel accuracy
rpin(2)=1e5;         % a priori upper bound
rpin(3)=-1e4;        % lower bound for TMIN
rpin(4)=50030;       % ACCELERATION coefficient
rpin(5)=1e8;         % feasibility radius
rpin(7)=1;           % tol for slow progress = rpin(7)*rpin(1)
rpin(8)=-1e4;        % default target for TMIN


% use ipin(7:8) to pass values of the number of dec. vars and of NLFC
ipin(7)=decnbr(LMIsys);
ipin(8)=lminbr(LMIsys)-nlfc;


% update the defaults from the calling list of gevp
if ~isempty(target),
  rpin(8)=target;
  % reset lower bound
  if target>1,
     rpin(3)=target/10;
  elseif target>0,
     rpin(3)=0;
  else
     rpin(3)=min(1.5*target,target-1);
  end
end


if ~isempty(tinit) & ~isempty(xinit),
  if length(xinit)~=decnbr(LMIsys),
     error(['XINIT should be of length ',num2str(decnbr(LMIsys))]);
  end
  ipin(4)=0;
  rpin(2)=max(100,10*tinit);  % reset upper bound
  rpin(6)=tinit;
end

if options(1)~=0,  rpin(1)=options(1); end    % rel accu
if options(2)~=0,  ipin(1)=options(2); end
if options(3)>0,
   rpin(5)=options(3);
elseif options(3)<0,
   ipin(9)=1;        % FLEXIBLE BOUND
   rpin(5)=1e9;
end
if options(4)>0,
  ipin(12)=max(3,options(4));  % SLOW PROGRESS
end


% data structure conversion
[izs,dzs]=nnsetup(LMIsys);

% add an extra cell to all arguments (cell 0 not used)
ipin=[0;ipin(:)];  rpin=[0;rpin(:)]; xinit=[0;xinit(:)];


% run the projective algorithm

if ~options(5),
 disp(sprintf(...
  '\n Solver for generalized eigenvalue minimization \n'));

  disp(sprintf(' Iterations   :    Best objective value so far \n '));
end


[xopt,tmin,report] = fpds(izs,dzs,ipin,rpin,xinit);


% post-analysis

if report(1) < 0,
   error(sprintf('\n NOT ENOUGH MEMORY! \n'));
   tmin=[]; xopt=[];
elseif report(2)<0,
   tmin=[]; xopt=[];
   if ipin(5)==0 & ~options(5),
     disp(sprintf('\n The LMI constraints were found INFEASIBLE \n'));
   end
else                   % feasible solution found
   xopt=xopt(2:length(xopt));
   xopt=xopt(:);

   if report(1)==3 & ~options(5),
     disp(sprintf([' Termination due to SLOW PROGRESS:',...
           '\n          the gen. eigenvalue t decreased by less than',...
           '\n          %1.3f%% during the last ',num2str(ipin(13)),...
                 ' iterations.\n'],100*rpin(2)));
   elseif report(1)==1,
     error(sprintf(...
       '\n Badly posed problem: the constraints  B(x) > 0  may be missing\n'));
   elseif ~options(5),
     disp(' ');
   end
end
