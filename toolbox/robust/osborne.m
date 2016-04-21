function [mu, Ascaled, logd] = osborne(A,K)
%OSBORNE Diagonal scaling using Osborne technique.
%
% [MU,ASCALED,LOGD] = OSBORNE(A)
% [MU,ASCALED,LOGD] = OSBORNE(A,K) produces the scalar upper bound MU on
% the structured singular value (ssv) computed via
%           mu = max(svd(diag(dosb)*A/diag(dosb)))
% where dosb obtained by applying the Osborne scaling technique.
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
%     ASCALED -- diag(dosb)*A/diag(dosb)
%     LOGD    -- dosb=exp(LOGD)) is Osborne scaling vector
%

% R. Y. Chiang & M. G. Safonov 8/15/88
% Copyright 1988-2004 The MathWorks, Inc.
%       $Revision: 1.7.4.3 $
% All Rights Reserved.
% --------------------------------------------------------------------

%
% ---------------- Tolerances used in this routine -------------------
%  If the matrix A is reducible, the Osborne theory does not apply
%  directly, but osborne.m compensates for this by computing the Osborne
%  scaling for a slightly perturbed matrix having a slightly larger
%  (i.e., slightly more conservative) SSV upper bound.  Reducibility
%  is detected by examining the norm of row and column of the matrix that
%  forms the actual diagonal scaling. The following constants are used by
%  this routine; they may be changed if necessary:

tol = 1/1.e120;     % Value for variable "tol" used
alfa0 = eps/10000;  % Initial Perturbation size
maxiter = 20;       % Maximum allowable iterations of perturbation loop
maxcounter = 10;    % Maximum allowable number of decreases in perturbation
% --------------------------------------------------------------------%-

[p,q] = size(A);
if nargin < 2,
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
aaa   = aa;
alfa0;              % Initial perturbation of aa
iter  = 0;          % Counter for while loop
counter = 0;        % Counter for perturbation decreases in loop
alfa = 0; lamp = 0; % This results in no perturbation in iteration 1
logd=zeros(n,1);
Ascaled=A;
d = eye(n);         % Osborne initial scaling
osbmaxiter = 20;    % Maximum Osborne iteratoins
%
% ------- Compute "Ascaled" and Osborne scaling "D" --------------
%
loop = 1;
while loop
   iter = iter+1;
   if (iter==maxiter)|(counter==maxcounter), % If this is maxiter-th iteration,
     loop=0;                            %    make it the last
     converge=0;
   end
   reducible=0;                 % Assume aaa is not reducible and
   perttoobig=0;                %   that perturb. is not too big
                                %   until proven otherwise
   aaa = aa+alfa*ones(n,n);     %   perturb the aa matrix
   % Starting Osborne iteration
   for osbiter = 1:osbmaxiter
      for i = 1:n
          aao = aaa - diag(diag(aaa));
          offrow = norm(aao(i,:));
          offcol = norm(aao(:,i));
          if (offcol < tol) | (offrow < tol)
             reducible = 1;
          end
          if ~reducible
              dhead(i,i) = sqrt(offrow/offcol);
              aaa(i,:) = aaa(i,:)/dhead(i,i);
              aaa(:,i) = aaa(:,i)*dhead(i,i);
              d(i,i) = d(i,i)/dhead(i,i);
          end
      end  % of For loop
   end     % of Osborne iteration loop
   lam = eig(aaa); % checking perturbation size
   [maxlam,ilam] = max(real(lam));
   if iter==1,
     lamp=maxlam;               % Unperturbed perron e-value
     alfa=alfa0*lamp;           % Perturbation size to be used in iter 2,
   end
   if iter>1,                   % If aaa is perturbed version of aa
     if maxlam>1.0001*lamp      %    determine if pert. was too big
        perttoobig=1;           %    to preserve perron e-value to
     else                       %    within .01 percent
        perttoobig=0;
     end
   end
   if ~reducible             % if nonreducibility confirmed by
       d = diag(d)/d(1,1);   % nomalize D scaling
       dinv = onesvec./d;
       dbar = d*dinv';
       logd = log(d) + logd;  % overwrite logd
       aa = dbar.*aa;         % overwrite aa
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
           converge=1;  % then convergence achieved;
           loop=0;      % exit while loop
       else             % else decrease perturbation:
           counter=counter+1;
           alfa=.01*alfa;
       end
   else % reducible     % else increase perturbation
     alfa=10000*alfa;
   end
end        % of perturbation loop
%
% -------- Compute the osborne singular value muosv -----------
%
musv  = max(svd(A));
if converge
    muosv = max(svd(Ascaled));
    if muosv > musv,          % make sure we never do worse than no scaling!
      logd = zeros(n,1);
      Ascaled = A;
      muosv = musv;
    end
else                          % if numerical problem
    muosv = musv;
    if nargout > 1
       disp('Warning OSBORNE.M: ASCALED, LOGD values are inaccurate!');
    end
end
mu = muosv;
%
% ------ End of OSBORNE.M --- RYC/MGS 12/26/90 %