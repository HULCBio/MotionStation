% function [x1,x2,fail,reig_min,epkgdif] = ric_schr(ham,epp,balflg)
%
%  Solves the eigenvalue problem associated with the
%  stabilizing solution (A+R*X stable) of the Riccati equation
%
%               A'*X + X*A + X*R*X - Q = 0.
%
%  A real Schur decomposition is used to obtain the stable
%  invariant subspace of the Hamiltonian matrix, HAM,
%  which contains the above variables in the following format:
%
%       HAM = [A  R; Q  -A'].
%
%  If HAM has no jw-axis eigenvalues, there exists n x n matrices
%  x1 and x2 such that [ x1 ; x2 ] spans the n-dimensional
%  stable-invariant subspace of HAM. IF x1 is invertible, then
%  X := x2/x1 satisfies the Riccati equation, and results in A+RX being
%  stable. the output flag FAIL is nominally 0. if there are jw-axis
%  eigenvalues, FAIL is set to 1. if there are an unequal
%  number of positive and negative eigenvalues, FAIL is set
%  to 2. if both conditions occur, FAIL = 3.
%
%  RIC_SCHR calls CSORD to produce an ordered complex Schur
%  form. This is converted to a real Schur form, and yields
%  the desired stable, invariant subspace of the Hamiltonian.
%  The minimum absolute value of the  real parts
%  of the eigenvalues is output to REIG_MIN.
%
%  BALFLG is a flag whether to balance HAM prior to solving the
%  Riccati equation. Setting BALFLG to 0 balances HAM and setting
%  BALFLG to 1 does not. The default is BALFLG set to 0.
%  EPKGDIF is a comparison of two different jw-axis tests.
%
%  See also: CSORD, HAMCHK, RIC_EIG, and SCHUR.

%   Copyright 1991-2004 MUSYN Inc. and The MathWorks, Inc.
% $Revision: 1.7.2.3 $

%  Add the option to balance the input Hamiltonian matrix prior
%  to operating on it.
%							23 Oct 92

function [r1,r2,fail,reig_min,epkgdif] = ric_schr(ham,epp,balflg)
  if nargin <= 0
    disp('usage: [x1,x2] = ric_schr(ham,epp,balflg)')
    return
  end
  r1 = []; r2 = []; fail = []; reig_min = []; epkgdif = [];
  [mtype,mrows,mcols,mnum] = minfo(ham);
  if mtype ~= 'cons'
    error(['RIC_SCHR is valid only with CONSTANT matrices'])
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
  if balflg == 0
    [tbal,ham] = balance(ham);
  end

  [nr,nc] = size(ham);
  [qn,tn,fail,reig_min,epkgdif] = csord(ham,epp,1,1,1);
%
% produce a real block-ordered decomposition of a real matrix, HAM
%
%      v' ham v = t = | t11  t12 |
%                     |  0   t22 |
%
%      t11 = t(1:np,1:np)
%      t22 = t(np+1:n,np+1,2*nps)
%
%
% find the orthonormal basis
%
  if fail == 0
    qord = [real(qn(:,1:np)) imag(qn(:,1:np))];
    [v,r] = qr(qord);
    t = v' * ham * v;
    r1 = v(1:np,1:np);
    r2 = v((np+1):2*np,1:np);
    if balflg == 0
      rmat = tbal*[r1;r2];
      r1 = rmat(1:np,:);
      r2 = rmat(np+1:2*np,:);
    end
  end
%
%