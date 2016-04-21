% [tmin,xfeas] = feasp(lmis,options,target)
%
% Solves the feasibility problem defined by the system LMIS
% of LMI constraints.  When the problem is feasible, the output
% XFEAS is a feasible value of the vector of (scalar) decision
% variables.
%
% Given a feasibility problem  of the form   L(x) < R(x),
% FEASP solves the  auxilliary convex program:
%
%        Minimize   t    subject to   L(x) < R(x) + t*I
%
% The system of LMIs is feasible iff. the global minimum TMIN is
% negative. The current best value of t is displayed by FEASP at
% each iteration.
%
% Input:
%  LMIS      array describing the system of LMI constraints
%  OPTIONS   optional:  five-entry vector of control parameters.
%            Default values are selected by setting OPTIONS(i)=0.
%             OPTIONS(1): not used
%             OPTIONS(2): max. number of iterations (Default=100)
%             OPTIONS(3): feasibility radius R.  R>0 constrains
%                         x to  x'*x  <  R^2    (Default=1e9).
%                         R<0 means "no bound"
%             OPTIONS(4): when set to an integer value  L > 1,
%                         forces termination when  t  has not
%                         decreased by more than 1%over the last
%                         L iterations  (Default = 10).
%             OPTIONS(5): when nonzero, the trace of execution is
%                         turned off.
%  TARGET    optional:  target for TMIN.  The code terminates as
%            soon as
%                       t < TARGET               (Default=0)
% Output:
%  TMIN      value of t upon termination.  The LMI system is
%            feasible   iff.  TMIN <= 0
%  XFEAS     corresponding minimizer.  If TMIN <= 0, XFEAS is
%            a feasible vector for the set of LMI constraints.
%            Use DEC2MAT to get the matrix variable values from
%            XFEAS.
%
%
% See also  MINCX, GEVP, DEC2MAT.

% Authors: A. Nemirovski and P. Gahinet  3/95
% Copyright 1995-2004 The MathWorks, Inc.
%       $Revision: 1.6.2.3 $


function [tmin,xfeas] = feasp(LMIsys,options,target)

if nargin<1 | nargin>3 ,
  error('usage: [tmin,xfeas] = feasp(lmisys,options,target)');
elseif size(LMIsys,1)<10 | size(LMIsys,2)>1,
  error('LMIS is an incomplete LMI description');
elseif any(LMIsys(1:8)<0),
  error('LMIS is not an LMI description');
elseif any(~LMIsys(1:3)),
  error('No matrix variable or term in this LMI sytem');
elseif nargin==1,
  options=zeros(1,5);
elseif isempty(options),
  options=zeros(1,5);
end
if nargin<3, target=[]; end

sizex=decnbr(LMIsys);   % # dec. vars
cc=0; cc(sizex+1,1)=1;


% DEFAULTS for control parameters

ipin(1)=100;         % max iter
ipin(2)=5;           % # primal dichotomy steps
ipin(3)=10;          % # dual Newton steps
ipin(4)=1;           % do not use xinit
ipin(5)=1;           % traces execution
ipin(6)=0;           % no protocol file
ipin(9)=2;           % RIGID BOUND on feasibility domain
ipin(10)=4;          % Cholesky -> QR
ipin(11)=1;          % No Memory Save
ipin(12)=10;         % # iterations for SLOW PROGRESS

rpin(1)=1.0e-1;      % default rel accuracy
rpin(2)=1.0e-10;     % unfeas. tol.
rpin(4)=30 ;         % ACCELERATION coefficient
rpin(5)=1.0e9;       % feasibility radius
rpin(6)=0;           % TARGET VALUE FOR THE OBJECTIVE
rpin(7)=1;           % tol for slow progress= rpin(7)*rpin(1)


% memory shortage fix
if options(4)>1,
  ipin(12)=options(4);  % SLOW PROGRESS
elseif options(4)==1,
  ipin(10)=0;
end


% update these defaults from the calling list of feasp
if length(options)~=5,
  error('OPTIONS must be a five-entry vector');
end
if options(2)~=0,  ipin(1)=options(2); end
if options(3)>0,
   rpin(5)=options(3);
elseif options(3)<0,
   ipin(9)=1;        % FLEXIBLE BOUND
   rpin(5)=1e10;
end
if options(5)~=0,  ipin(5)=0; end                 % trace off
if ~isempty(target),  rpin(6)=target; end         % target for TMIN


% data structure conversion

[izs,dzs]=nnsetup(LMIsys);


% add an extra cell to all arguments (cell 0 not used)

cc=[0;cc];   ipin=[0;ipin(:)];  rpin=[0;rpin(:)];


% run the projective algorithm

xfeas=[]; tmin=[];

if ~options(5),
  disp(sprintf(...
   '\n Solver for LMI feasibility problems L(x) < R(x)'));
  disp('    This solver minimizes  t  subject to  L(x) < R(x) + t*I');
  disp(sprintf('    The best value of t should be negative for feasibility\n'));

  disp(sprintf(' Iteration   :    Best value of t so far \n '));
end


[xfeas,tmin,report] = feaslv(cc,izs,dzs,ipin,rpin);


% post-analysis

if report(1) < 0,
   error(sprintf('\n NOT ENOUGH MEMORY! \n'));
   tmin=[]; xfeas=[];
elseif report(2)<0,
   disp(sprintf(['\n   Failure of FEASP\n']));
   tmin=[]; xfeas=[];
else                   % feasible solution found
   xfeas=xfeas(2:length(xfeas)-1);
   xfeas=xfeas(:);

   if options(5), return, end

   if report(1)==3,
     disp(sprintf([' Termination due to SLOW PROGRESS:',...
           '\n          t was decreased by less than %1.3f%% during',...
           '\n          the last ',num2str(ipin(13)),...
                 ' iterations.\n'],100*rpin(2)));
   end


   if tmin > 1.0e-3,
      disp(...
        sprintf('\n These LMI constraints were found infeasible \n'));
   elseif tmin > 0,
      disp(sprintf(...
      ['\n Marginal infeasibility: these LMI constraints may be' ...
       '\n          feasible but are not strictly feasible\n']));
   else
      disp(' ');
   end

end
