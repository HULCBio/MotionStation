function [mu, Ascaled, logd] = psv(A,K)
%PSV Diagonal scaling via Perron eigenvector approach.
%
% [MU,ASCALED,LOGD] = PSV(A)
% [MU,ASCALED,LOGD] = PSV(A,K) produces the scalar upper bound MU on
% the structured singular value (ssv) computed via
%           mu = max(svd(diag(dperron)*A/diag(dperron)))
% where dperron is obtained by applying the Perron eigenvector scaling
% technique of Safonov (IEE Proc., Pt. D, Nov. '82) to the matrix A.
%
% Input:
%     A  -- a pxq complex matrix whose ssv is to be computed
% Optional input:
%     K  -- an nx1 or nx2 matrix whose rows are the uncertainty block sizes
%           for which the ssv is to be evaluated; K must satisfy
%           sum(K) == [q,p].  If only the first column of K is given then the
%           uncertainty blocks are taken to be square, as if K(:,2)=K(:,1).
% Outputs:
%     MU      -- An upper bound on the structured singular value of A
%     ASCALED -- diag(dperron)*A/diag(dperron)
%     LOGD    -- dperron=exp(LOGD)) is perron scaling vector
%

% R. Y. Chiang & M. G. Safonov 8/15/88
% Copyright 1988-2004 The MathWorks, Inc.
%       $Revision: 1.7.4.3 $
% All Rights Reserved.
% --------------------------------------------------------------------
%

% ---------------- Tolerances used in this routine -------------------
%  If the matrix A is reducible, the Perron theory does not apply
%  directly, but psv.m compensates for this by computing the perron
%  scaling for a slightly perturbed matrix having a slightly larger
%  (i.e., slightly more conservative) perron eigenvalue.  Reducibility
%  is detected by examining the largest e-value and associated e-vector.
%  The Perron-Frobenius theory says that a non-negative matrix is
%  irreducible if and only if both it has a largest eigenvalue which is
%  real and multiplicity one and the associated e-vector has all strictly
%  positive components.  The following constants are used by this
%  routine; they may be changed if necessary:

tol  = 1/1e120;       % Value for variable "tol" used
                      %    test positivity of perron e-vectors

alfa0 = eps/10000;  % 2*lamp*alfa0*norm(abs(A)) is initial perturbation
                      %    size (used only when unperturbed perron
                      %    e-vector is not strictly positive)

maxiter = 20;         % Maximum allowable iterations of perturbation loop
maxcounter = 10;      % Maximum allowable number of decreases in perturbation
% --------------------------------------------------------------------%-

[p,q] = size(A);
if nargin < 2
   K = ones(q,2);   % set blocksize to default 1x1
elseif  max(size(K))==0,
   K = ones(q,2);   % set blocksize to default 1x1
end

K = [K,K]; K=K(:,1:2);            % set K(:,2)=K(:,1) if K(:,2) is not present
n = size(K)*[1;0];                % number of uncertainty blocks
K2c = K(:,1);
K1c = K(:,2);
if sum(abs(K1c))~= p | sum(abs(K2c))~= q,
    error('K and A are not dimensionally compatible')
end
%
% ------ form matrix aa of max singular values of blocks of A
onesvec = ones(n,1);

if n < p | n < q,
   aa = zeros(n,n);
   r=[0;conv(K1c,onesvec)];
   c=[0;conv(K2c,onesvec)];
   for i = 1:n
      for j = 1:n
          aa(i,j) = max(svd(A(r(i)+1:r(i+1),c(j)+1:c(j+1))));
      end
   end
else
   aa = abs(A);
end
%
% ----- Initialize constants and temporary variables------
% -------------used inside while loop below --------------
aaa = aa;
alfa0;              % Initial perturbation of aa
iter=0;             % Counter for while loop
counter=0;          % Counter for perturbation decreases in loop
alfa=0;lamp=0;      % This results in no perturbation in loop iteration no. 1
logd=zeros(n,1);
Ascaled=A;
%
% ------- Compute Ascaled and perron scaling d --------------
%
loop = 1;                      % Execute while loop
while loop,                    % Compute perron e-vector
  iter=iter+1;
  if (iter==maxiter)|(counter==maxcounter), % If this is maxiter-th iteration,
     loop=0;                            %    make it the last
     converge=0;
  end
  reducible=0;                 % Assume aaa is not reducible and
  perttoobig=0;                %   that perturb. is not too big
                               %   until proven otherwise
  aaa = aa+alfa*ones(n,n);%   perturb the aa matrix
  % compute the right perron eigenvector xp of aaa
  [x,lam] = eig(aaa);
  lam = diag(lam);
  [maxlam,i]=max(real(lam));
  if iter==1,
     lamp=maxlam;               % Unperturbed perron e-value
     alfa=alfa0*lamp;           % Perturbation size to be used in iter 2,
  end
  xp=x(:,i);                    % Perron e-vector of aaa modulo sign
  if iter>1,                    % If aaa is perturbed version of aa
     if maxlam>1.0001*lamp,          %    determine if pert. was too big
        perttoobig=1;           %    to preserve perron e-value to
     else                       %    within .01 percent
        perttoobig=0;
     end
  end

  % Check reducibility of aaa
  [mult,junk] = size(find( lam>0.9999999*maxlam*ones(n,1) ));
  % mult = 'multiplicity of max e-value of aaa'
  if mult==1,
     [junk,i]=max(abs(xp));
     xp=xp*sign(xp(i))';            % Fix sign of xp, if needed
     if min(xp)<tol,                   % Check reducibility of aaa
        reducible=1;                %  ( theory says irreducible iff
     end                            %    (xmin>0  & mult == 1) )
  else
     reducible=1;
  end
  if ~reducible,               % If aa not reducible, go ahead and
    [y,lam] = eig(aaa');       %    compute left perron e-vector
    lam = diag(lam);
    [maxlam,i] = max(real(lam));
    yp=y(:,i);                     % left perron e-vector modulo sign
    [junk,i]=max(abs(yp));
    yp=yp*sign(yp(i))';            % Fix sign of yp, if needed
                                   % Now double check reducibility (yp>0)--
    if min(yp)<tol,                %   theory says yp>0 since we already
       reducible=1;                %   have xp>0, but we need to check
    end                            %   again because of finite precision
  end
  if ~reducible                  % If nonreducibility confirmed by yp>0,
    d = abs(sqrt(yp)./sqrt(xp));%     then compute perron scaling d,
    dinv = onesvec./d;
    dbar = d * dinv';
    logd = log(d)+logd;          %     overwrite logd,
    aa=dbar.*aa;                %     overwrite aa with scaled aa
    if n==p & n==q,
      Ascaled = dbar.*Ascaled;  %     and overwrite Ascaled.
    else
      for i = 1:n
         for j = 1:n
            Ascaled(r(i)+1:r(i+1),c(j)+1:c(j+1)) ...
               = dbar(i,j)*Ascaled(r(i)+1:r(i+1),c(j)+1:c(j+1));
         end
      end
    end
    if ~perttoobig   % If everything is ok
       converge=1;                 % then convergence achieved;
       loop=0;                     % exit while loop
    else             % else decrease perturbation:
       counter=counter+1;
       alfa=.01*alfa;
    end
  else % reducible   % else increase perturbation
     alfa=10000*alfa;
  end
end % of while loop

%
% -------- Compute the perron singular value mupsv -----------
%
musv  = max(svd(A));
if converge,
    mupsv = max(svd(Ascaled));
    if mupsv > musv,          % make sure we never do worse than no scaling!
      logd = zeros(n,1);
      Ascaled = A;
      mupsv = musv;
    end
else                          % If numerical problems,
    mupsv=musv;               %    set mupsv=musv
    if nargout>1,
       disp('Warning PSV.M:  ASCALED, LOGD values are inaccurate')
    end
end
mu = min(mupsv,lamp);      % if the perron eigenvalue is smaller
                           % then use it as mu
%
% ------ End of PSV.M --- RYC/MGS 8/16/88, 12/26/90 %