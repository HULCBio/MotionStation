% function [v,t,flgout,reig_min,epkgdif] = csord(a,epp,flgord,flgjw,flgeig)
%
%  This function produces an ordered complex schur matrix, T,
%  where
%              v' * a * v  = t = |t11  t12|
%                                | 0   t22|.
%  and V'V = eye().
%  The MATLAB function SCHUR is called, which results in an
%  unordered Schur form matrix. A subroutine called CGIVENS
%  is used to form a complex Givens rotation matrix which
%  orders the T matrix in a user-defined manner. A series
%  of input flags can be set:
%
%  EPP           user supplied zero tolerance (default EPP=1e-9)
%  FLGORD = 0    order eigenvalues in ascending real part (default)
%         = 1    partial real part ordering, <0 , =0, >0
%  FLGJW  = 0    no exit condition on eigenvalue location (default)
%         = 1    exit if jw-axis eigenvalue is detected (see JWHAMTST)
%  FLGEIG = 0    no exit condition on half-plane eigenvalue
%                distribution (default)
%         = 1    exit if
%                length(real(eigenvalue)>0) ~= length(real(eigenvalue)<0)
%
%
%  The output flag FLGOUT is nominally 0. If there are jw-axis
%  eigenvalues, FLGOUT is set to 1. If there are an unequal
%  number of positive and negative eigenvalues, FLGOUT is set
%  to 2. If both conditions occur, FLGOUT = 3. The minimum
%  real part of the eigenvalues is output in REIG_MIN.
%  EPKGDIF is a comparison of two different jw-axis tests.
%
%  See also: RIC_SCHR, SCHUR, and RSF2CSF.

%   Copyright 1991-2004 MUSYN Inc. and The MathWorks, Inc.
% $Revision: 1.7.2.3 $

%  The RIC_SCHR routine uses CSORD to solve stabilizing
%  solutions to matrix Ricatti equations. In that case, the
%  a matrix has a special structure, and there are failure modes
%  which can be flagged, thus avoiding extra, unnecessary
%  computations.

function [v,t,flgout,reig_min,epkgdif] = csord(a,epp,flgord,flgjw,flgeig)

 if nargin < 1
   disp(['usage: [v,t,flgout] = csord(a,epp,flgord,flgjw,flgeig)'])
   return
 elseif nargin == 1
   epp = 1e-9;
   flgord = 0;
   flgjw = 0;
   flgeig = 0;
  elseif nargin == 2
   flgord = 0;
   flgjw = 0;
   flgeig = 0;
  elseif nargin == 3
   flgjw = 0;
   flgeig = 0;
  elseif nargin == 4
   flgeig = 0;
  end

 [nc,nr] = size(a);
 if nc ~= nr,
   disp('Matrix must be square.')
   return
 end;

 flgout = 0;
%
% complex schur decomposition
%
 [v,t] = schur(a);
 [v,t] = rsf2csf(v,t); % change into complex Schur form if it isn't
 evls = diag(t);
 [ntc,ntr] = size(t);
%
% check if there are any jw-axis eigenvalues in the matrix (used
% in HINFSYN and HINFFI routines)
%

epmeth = 0;
kgmeth = 0;
outexact = [];
reig_min = min(abs(real(evls)));
if reig_min<epp
  epmeth = 1;
end
if norm(imag(a))<10*epp
	n = max(size(a));
	[tmp,indmin] = min(abs(evls*ones(1,n)+ones(n,1)*evls'));
	loc = find( indmin==[1:n] );
	if ~isempty(loc) == 1
  		kgmeth = 1;
	end
end
if epmeth == 0 & kgmeth == 0
  epkgdif = 0;
elseif epmeth == 1 & kgmeth == 1
  epkgdif = 0;
elseif epmeth == 0 & kgmeth == 1
  epkgdif = 1;
elseif epmeth == 1 & kgmeth == 0
  epkgdif = 2;
end
if kgmeth == 1
  flgout = 1;    % there is a jw axis eigenvalue
  if flgjw == 1
    t = [];
    v = [];
    return
  end
end

neg_eig = length(find(real(diag(t))<0));
pos_eig = length(find(real(diag(t))>0));
if neg_eig ~= ntc/2 | pos_eig ~= ntc/2
  if flgout == 0
    flgout = 2;
  else
    flgout = 3;
  end
  if flgeig == 1
    t = [];
    v = [];
    return
  end
end
% order evals
 if flgord == 1                      % partial ordering -0+
   if flgjw == 1                     % Riccati solution
     for i = 1 : ntc*ntc/4
       for k = 1 : (ntc-1)
         if (real(t(k,k))>0.) & (real(t(k+1,k+1))<0.)
           [c,s] = cgivens( t(k,k+1), t(k,k)-t(k+1,k+1) );
           t(:,k:k+1) = t(:,k:k+1)*[c s;-s' c];
           t(k:k+1,:) = [c s;-s' c]'*t(k:k+1,:);
	   v(:,k:k+1) = v(:,k:k+1)*[c s;-s' c];
         end
       end
       mxneg = max(find(real(diag(t))<0));
       mnpos = min(find(real(diag(t))>0));
%
%    check if the ordering of the Schur matrix is finished
%
       if (mxneg <  mnpos)
         break               % done partial ordering
       end
     end
   else
     for i = 1 : ntc*ntc/4
       for k = 1 : (ntc-1)
         if (real(t(k,k))>=0.) & (real(t(k+1,k+1))<=0.)
           [c,s] = cgivens( t(k,k+1), t(k,k)-t(k+1,k+1) );
           t(:,k:k+1) = t(:,k:k+1)*[c s;-s' c];
           t(k:k+1,:) = [c s;-s' c]'*t(k:k+1,:);
	   v(:,k:k+1) = v(:,k:k+1)*[c s;-s' c];
         end
       end
       mxneg = max(find(real(diag(t))<0));
       mxzer = max(find(real(diag(t))==0));
       mnzer = min(find(real(diag(t))==0));
       mnpos = min(find(real(diag(t))>0));
%
%    check if the ordering of the Schur matrix is finished
%
       if (mxneg < mnzer) & (mxzer < mnpos)
         break               % done partial ordering
       end
     end
   end %if flgjw
 else                         %  full ordering
   for i = 1 : ntc*ntc/4
     for k = 1 : (ntc-1)
       if (real(t(k,k)) > real(t(k+1,k+1)))
         [c,s] = cgivens( t(k,k+1), t(k,k)-t(k+1,k+1) );
         t(:,k:k+1) = t(:,k:k+1)*[c s;-s' c];
         t(k:k+1,:) = [c s;-s' c]'*t(k:k+1,:);
	        v(:,k:k+1) = v(:,k:k+1)*[c s;-s' c];
       end
     end
     if min(diff(real(diag(t)))) >= 0
       break               % done full ordering
     end
   end
 end
%
%