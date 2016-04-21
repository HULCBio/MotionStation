% function [x1,x2,fail,reig_min,epkgdif] = ric_eig(ham,epp,balflg)
%
%  Solves the eigenvalue problem associated with the
%  stabilizing solution (A+R*X stable) of the Riccati equation
%
%               A'*X + X*A + X*R*X - Q = 0.
%
%  An eigenvalue decomposition is used to obtain the stable
%  invariant subspace of the Hamiltonian matrix, HAM,
%  which contains the above variables in the following format:
%
%       HAM = [A  R; Q  -A'].
%
%  If HAM has no jw axis eigenvalues, there exists n x n matrices
%  X1 and X2 such that [ X1 ; X2 ] spans the n-dimensional
%  stable-invariant subspace of HAM. IF X1 is invertible, then
%  X = X2/X1 satisfies the Riccati equation, and results in A+RX being
%  stable. FAIL is returned with a value of 1 if jw-axis eigenvalues
%  of HAM are found. An eigenvalue is considered to be purely
%  imaginary if the magnitude of the real part is less than EPP.
%  The minimum real part of the eigenvalues is returned in REIG_MIN.
%  The default value for EPP is 1e-10.
%
%  BALFLG determines whether to balance HAM prior to solving the
%  Riccati equation. Setting BALFLG to 0 balances HAM and setting
%  BALFLG to a nonzero value does not. The default is BALFLG set to 0.
%
%  This can give incorrect results if HAM is not diagonalizable,
%  in this case it is better to use RIC_SCHR.
%  EPKGDIF is a comparison of two different jw-axis tests.
%
%  See also: EIG and RIC_SCHR.

%   Copyright 1991-2004 MUSYN Inc. and The MathWorks, Inc.
% $Revision: 1.7.2.3 $

function [r1,r2,fail,reig_min,epkgdif] = ric_eig(ham,epp,balflg)
  if nargin <= 0
    disp('usage: [x1,x2] = ric_eig(ham,epp,balflg)')
    return
  end
  r1 = []; r2 = []; fail = []; reig_min = []; epkgdif = [];
  [mtype,mrows,mcols,mnum] = minfo(ham);
  if mtype ~= 'cons'
    error(['RIC_EIG is valid only with CONSTANT matrices'])
    return
  end
  if nargin == 1
    epp = 1e-10;
    balflg = 0;
  elseif nargin == 2
    balflg = 0;
  end
  np = mrows/2;
  fail = 0;
  if  balflg == 0
    [v,d] = eig(ham);
  else
    [v,d] = eig(ham,'nobalance');
  end
  evls = diag(d);
%
% check there are no jw-axis eigenvalues in the Hamiltonian matrix
%
  epmeth = 0;
  kgmeth = 0;
  outexact = [];
  reig_min = min(abs(real(evls)));
  if reig_min<epp
    epmeth = 1;
  end
  n = max(size(ham));
  [tmp,indmin] = min(abs(evls*ones(1,n)+ones(n,1)*evls'));
  loc = find( indmin==[1:n] );
  if ~isempty(loc) == 1
    kgmeth = 1;
  end
  if epmeth == 0 & kgmeth == 0
    epkgdif = 0;
  elseif epmeth == 1 & kgmeth == 1
    epkgdif = 0;
  elseif epmeth == 0 & kgmeth == 1
    epkgdif = 1;
  else
    epkgdif = 2;
  end

  if kgmeth == 1
    fail = 1;
  else
    v2 = zeros(2*np,np);
    i2 = 1;
    for i=1:2*np
      if real(d(i,i))<0
        v2(:,i2)=v(:,i);
        i2=i2+1;
      end
    end
    if i2 == np+1
      r1 = v2(1:np,:);
      r2 = v2((np+1):2*np,:);
    else
      fail = 1;
    end
  end
%
%