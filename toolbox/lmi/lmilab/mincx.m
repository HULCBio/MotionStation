% [copt,xopt] = mincx(lmis,c,options,xinit,target)
%
% Solves the LMI problem:
%
%      Minimize    c'*x   subject to    L (x)  <   R(x)
%
% where x is the vector of DECISION VARIABLES.
%
% Input:
%  LMIS      description of the system of LMI constraints
%  C         vector of the same size as  x  (see DECNBR).  Use
%            DEFCX  to specify the objective  c'*x  directly
%            in terms of matrix variables
%  OPTIONS   optional:  five-entry vector of control parameters.
%            The default value is used when OPTIONS(i)=0 .
%             OPTIONS(1): relative accuracy required on the optimal
%                         value of the objective     (Default = 0.01)
%             OPTIONS(2): max. number of iterations  (Default=100)
%             OPTIONS(3): feasibility radius R.  R>0 constrains x
%                         to x'*x < R^2.  R<0 means "no bound"
%                                                    (Default=1e9)
%             OPTIONS(4): integer value L.   The code terminates
%                         when the objective value has decreased
%                         by less than OPTIONS(1) during the last
%                         L iterations               (Default=10)
%             OPTIONS(5): when nonzero, the trace of execution is
%                         turned off                 (Default=0)
%  XINIT     optional:  initial guess for X  ([] if none, ignored
%                       when unfeasible)
%  TARGET    optional:  target for the objective value.
%            The code terminates as soon as a feasible x is found
%            such that
%                        c'*x  < TARGET            (Default=-1e20)
% Output:
%  COPT      global minimum of the objective c'*x
%  XOPT      minimizing value of the vector x of decision variables.
%            Use DEC2MAT to get the corresponding matrix variable
%            values.
%
%
% See also  FEASP, GEVP, DEFCX, DEC2MAT.

% Authors: A. Nemirovski and P. Gahinet  3/95
% Copyright 1995-2004 The MathWorks, Inc.
%       $Revision: 1.7.2.3 $


function [copt,xopt] = mincx(LMIsys,c,options,xinit,target)

if nargin<2,
  error('usage: [copt,xopt]=mincx(lmisys,c,{options,xinit,target})');
elseif size(LMIsys,1)<10 | size(LMIsys,2)>1,
  error('LMIS is an incomplete LMI system description');
elseif any(LMIsys(1:8)<0),
  error('LMIS is not an LMI description');
elseif any(~LMIsys(1:3)),
  error('No matrix variable or term in this LMI sytem');
elseif length(c)~=decnbr(LMIsys),
  error(['The vector C should be of length ',num2str(decnbr(LMIsys))]);
end
if nargin<4, xinit=[]; end
if nargin<5, target=[]; end

if nargin==2,
   options=zeros(1,5);
elseif isempty(options),
   options=zeros(1,5);
elseif length(options)~=5,
  error('OPTIONS must be a five-entry vector');
end

c=c(:);


% DEFAULTS for control parameters

ipin(1)=100;         % max iter
ipin(2)=5;           % # primal dichotomy steps
ipin(3)=10;          % # dual Newton steps
ipin(4)=1;           % do not use xinit
ipin(5)=~options(5); % trace of execution
ipin(6)=0;           % no protocol file
ipin(9)=2;           % RIGID BOUND on feasibility domain
ipin(10)=6;          % IC+CG/QR
ipin(11)=1;          % No Memory Save
ipin(12)=10;         % # iterations for SLOW PROGRESS

rpin(1)=1.0e-2;      % default rel accuracy
rpin(2)=1.0e-10;     % unfeas. tol.
rpin(4)=30;          % ACCELERATION coefficient
rpin(5)=1.0e9;       % feasibility radius
rpin(6)=-1.0e20;     % no target value for the objective
rpin(7)=1;           % tol for slow progress= rpin(7)*rpin(1)


% memory shortage fix
if options(4)>1,
  ipin(12)=options(4);  % SLOW PROGRESS
elseif options(4)==1,
  ipin(10)=0;
end


% update these defaults from the calling list of mincx

if ~isempty(target), rpin(6)=target; end
if ~isempty(xinit),
  if length(xinit)~=decnbr(LMIsys),
     error(['XINIT should be of length ',num2str(decnbr(LMIsys))]);
  end
  ipin(4)=0;
end

if options(1)~=0,  rpin(1)=options(1); end        % rel accu
if options(2)~=0,  ipin(1)=options(2); end
if options(3)>0,
   rpin(5)=options(3);
elseif options(3)<0,
   ipin(9)=1;        % FLEXIBLE BOUND
   rpin(5)=1e9;
end



% data structure conversion
[izs,dzs]=nnsetup(LMIsys);


% add an extra cell to all arguments (cell 0 not used)
c=[0;c]; ipin=[0;ipin(:)];  rpin=[0;rpin(:)]; xinit=[0;xinit(:)];


% run the projective algorithm
if ~options(5),
  disp(sprintf(...
  '\n Solver for linear objective minimization under LMI constraints \n'));
  disp(sprintf(' Iterations   :    Best objective value so far \n '));
end


[xopt,report] = pds(c,izs,dzs,ipin,rpin,xinit);



% post-analysis
if report(1) < 0,
   error(sprintf('\n NOT ENOUGH MEMORY! \n'));
   xopt=[]; copt=[];
elseif report(2)<0,
   xopt=[]; copt=[];
   if ~options(5),
      disp(sprintf('\n The LMI constraints were found INFEASIBLE \n'));
   end
else                   % feasible solution found
   xopt=xopt(:);
   copt = c'*xopt;
   xopt=xopt(2:length(xopt));

   if report(1)==3 & ~options(5),
     disp(sprintf([' Termination due to SLOW PROGRESS:',...
           '\n          the objective was decreased by less than ',...
           '\n          %1.3f%% during the last ',num2str(ipin(13)),...
                 ' iterations.\n'],100*rpin(2)));
   elseif ~options(5),
     disp(' ');
   end
end
