% function [k,g,norms,kfi,gfi,hamx,hamy] = ...
%		h2syn(plant,nmeas,ncon,ricmethod,quiet)
%
%   Calculate the H2 optimal controller (K) and the closed loop
%   system (G) for the linear fractional interconnection structure
%   P.  NMEAS and NCON are the dimensions of the measurement outputs
%   from P and the controller inputs to P. RICMETHOD determines the
%   method  used to solve the Riccati equations.
%
%   inputs:
%     PLANT   -   system interconnection structure
%     NMEAS   -   measurements output to controller
%     NCON    -   control inputs
%     RICMETHOD -   Riccati solution via
%                    1 - eigenvalue reduction (balance)
%                   -1 - eigenvalue reduction (no balancing)
%                    2 - real schur decomposition  (balance,default)
%                   -2 - real schur decomposition  (no balancing)
%     QUIET   -   prints out minimum eigenvalues of X2 and Y2
%		     0 - do not print results
%		     1 - print results to command window (default)
%
%   outputs:
%     K      -  H2 optimal controller
%     G      -  closed-loop system with H2 optimal controller
%     NORMS  -  norms of 4 different quantities, full information
%               control cost (FI), output estimation cost (OEF),
%               direct feedback cost (DFL) and full control cost (FC).
%               norms = [FI OEF DFL FC];
%		h2norm(g) = sqrt(FI^2 + OEF^2) = sqrt(DFL^2 + FC^2)
%     KFI    -  full information/state feedback control law
%     GFI    -  full information/state feedback closed-loop system
%     HAMX   -  X Hamiltonian matrix
%     HAMY   -  Y Hamiltonian matrix
%
%   See also: H2NORM, HINFSYN, HINFFI, HINFNORM, RIC_EIG and RIC_SCHR.

%   Copyright 1991-2004 MUSYN Inc. and The MathWorks, Inc.
% $Revision: 1.8.2.3 $

function [k,g,norms,kfi,gfi,hamx,hamy] = h2syn(plant,p2,m2,ricmethod,quiet)

if nargin ~= 3 & nargin ~=4 & nargin~=5,
  disp('usage: [k,g,norms,kfi,gfi,hamx,hamy] = h2syn(plant,nmeas,ncon,ricmethod)')
  return
end

if nargin == 3,
  ricmethod = 2;
  quiet = 1;
end
if nargin == 4,
  quiet = 1;
end

%    check the dimensions and assumptions of the problem.
%    D11 must be zero, and here we will assume that D22 is
%    also zero.  D12 and D21 must also be of appropriate rank.

[a,b,c,d] = unpck(plant);
[anom,bnom,cnom,dnom] = unpck(plant);
nx = max(size(a));
[i,m] = size(b);
[p,i] = size(c);
if m <= m2,
  disp('control input dimension incorrect')
  return
end
if p <= p2,
  disp('measurement output dimension incorrect')
  return
end
p1 = p - p2;
m1 = m - m2;

%    now introduce a unitary scaling (qin, qout) on the inputs and outputs,
%    and a change of basis (tin, tout) on the controller measurements
%    and controls.  This means that the d term meets the assumptions
%    of the formulae.

%    select out the d12 and d21 terms.

d12 = d(1:p1,m1+1:m);
d21 = d(p1+1:p,1:m1);

%    get qout and rin such that [qout*d12*rin] = [0;I]
%    This is done by rearranging the result of a qr decomposition.

[q,r] = qr(d12);
if rank(r) ~= m2,
 disp('d12 does not have full column rank')
 return
end
qout = [q(:,(m2+1):p1),q(:,1:m2)]';
rin = eye(m2)/(r(1:m2,:));

%    get qin and rout such that [rout*d21*qin] = [0,I]
%    Again this is done by rearranging the result of a qr decomposition.

[q,r] = qr(d21');
if rank(r) ~= p2,
    disp('d21 does not have full row rank')
    return
    end
qin = [q(:,(p2+1):m1),q(:,1:p2)];
rout = eye(p2)/(r(1:p2,:)');

%    now scale the inputs and outputs appropriately
%    Note that the controller scaling (rin, rout) must
%    be included in the calculation of k.  qin and qout
%    do not affect the assumptions of the problem.

c = daug(qout,rout)*c;
b = b*daug(qin,rin);
d = daug(qout,rout)*d*daug(qin,rin);

%    now decompose the new system into its appropriate parts

c1 = c(1:p1,:);
c2 = c(p1+1:p,:);
b1 = b(:,1:m1);
b2 = b(:,m1+1:m);

%  d12 and d21 are hardwired to the form obtained by the scaling and
%  unitary transformation above.  This will help eliminate rounding errors.

d11 = d(1:p1,1:m1);
d12 = [zeros(p1-m2,m2);eye(m2)];
d21 = [zeros(p2,m1-p2),eye(p2)];
d22 = d(p1+1:p,m1+1:m);

%    check for d11 being zero.

if any(any(d11 ~= 0)),
  disp('d11 is non zero')
  return
end

%    now form the hamiltonian for X2

Ah = a - b2*d12'*c1;
Eh = daug(eye(p1-m2),zeros(m2,m2));

if abs(ricmethod) == 1 | abs(ricmethod) == 2,
    hamx = [Ah, -b2*b2'; -c1'*Eh*c1, -Ah'];
    if ricmethod == 1,
%
% Solve the Riccati equation using eigenvalue decomposition
%       - Balance Hamiltonian
%
      [X1,X2,fail,xeig_min] = ric_eig(hamx,1e-13);
    elseif ricmethod == -1,
%
% Solve the Riccati equation using eigenvalue decomposition
%       - No Balancing of Hamiltonian Matrix
%
      [X1,X2,fail,xeig_min] = ric_eig(hamx,1e-13,1);
    elseif ricmethod == 2,
%
% Solve the Riccati equation using real schur decomposition
%       - Balance the Hamiltonian Matrix
%
      [X1,X2,fail,xeig_min] = ric_schr(hamx,1e-13);
    elseif ricmethod == -2,
%
% Solve the Riccati equation using real schur decomposition
%       - No Balancing of Hamiltonian Matrix
%
      [X1,X2,fail,xeig_min] = ric_schr(hamx,1e-13,1);
    end
    if fail ~= 0,
      disp('Decomposition of X2 failed')
      return
    end
    X2 = real(X2/X1);
else
    disp('invalid Riccati method')
    return
end

if quiet == 1
	fprintf('minimum eigenvalue of X2: %e\n',xeig_min);
end

%    now form the hamiltonian for Y2

Aj = a - b1*d21'*c2;
Ej = daug(eye(m1-p2),zeros(p2,p2));



if abs(ricmethod) == 1 | abs(ricmethod) == 2,
    hamy = [Aj', -c2'*c2; -b1*Ej*b1', -Aj];
    if ricmethod == 1,
%
% Solve the Riccati equation using eigenvalue decomposition
%       - Balance Hamiltonian
%
      [Y1,Y2,fail,yeig_min] = ric_eig(hamy,1e-13);
    elseif ricmethod == -1,
%
% Solve the Riccati equation using eigenvalue decomposition
%       - No Balancing of Hamiltonian Matrix
%
      [Y1,Y2,fail,yeig_min] = ric_eig(hamy,1e-13,1);
    elseif ricmethod == 2,
%
% Solve the Riccati equation using real schur decomposition
%       - Balance the Hamiltonian Matrix
%
      [Y1,Y2,fail,yeig_min] = ric_schr(hamy,1e-13);
    elseif ricmethod == -2,
%
% Solve the Riccati equation using real schur decomposition
%       - No Balancing of Hamiltonian Matrix
%
      [Y1,Y2,fail,yeig_min] = ric_schr(hamy,1e-13,1);
    end
    Y2 = real(Y2/Y1);
    if fail ~=0,
      disp('Decomposition of Y2 failed')
      return
    end
else
    disp('invalid Riccati method')
    return
end

if quiet == 1
	fprintf('minimum eigenvalue of Y2: %e\n',yeig_min);
end

% form the general controller (as an LFT)

f2 = -d12'*c1 - b2'*X2;
h2 = -b1*d21' - Y2*c2';

% include the scaling matrices into d22 feedback problem

ak = a + h2*c2 + b2*f2 + h2*d22*f2;

% This section of the code can be used to generate all controllers
%
% ak = a + h2*c2 + b2*f2 + h2*d22*f2;
% bk = [-h2, (h2*d22 + b2)];
% ck = [f2; (-d22*f2 - c2)];
% dk = [zeros(m2,p2), eye(m2,m2); eye(p2,p2), -d22];

kgen = pck(ak,-h2,f2,zeros(m2,p2));

k = mmult(rin,mmult(kgen,rout));
g = starp(plant,k,p2,m2);

%
%  construct the full information controller and closed-loop system
%
if nargout >= 4
    afi = anom;
    bfi = bnom;
    cfi = [cnom(1:p1,1:nx); eye(nx)];
    dfi = [zeros(p1,m1) dnom(1:p1,m1+1:m); zeros(nx,m)];
    pfi = pck(afi,bfi,cfi,dfi);
    kfi = rin*f2;
    gfi = starp(pfi,kfi,nx,m2);
end

% construct the norm for the full info and output injection cases

if nargout >= 3
    FI  = sqrt(trace((b1)'*X2*(b1)));
    OEF = sqrt(trace((f2)*Y2*(f2)'));
    DFL = sqrt(trace((h2)'*X2*(h2)));
    FC  = sqrt(trace((c1)*Y2*(c1)'));
    norms = [ FI OEF DFL FC];
end
%
%