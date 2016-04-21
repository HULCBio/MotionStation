function [xv,lmb,iresult] = sptarn(A,B,lb,ub,spd,tolconv,jmax,maxmul)
%SPTARN   Solve generalized sparse eigenvalue problem.
%
%       [XV,LMB,IRESULT] = SPTARN(A,B,LB,UB,SPD,TOLCONV,JMAX,MAXMUL)
%       Finds eigenvalues of pencil (A-LMB*B)*XV=0 in interval LB < LMB <= UB.
%
%       Input data:
%       A, B sparse matrices
%       LB lower bound if -Inf all eigenvalues to the left of UB sought
%       UB upper bound if +Inf all eigenvalues to the right of LB sought
%       One of LB, UB must be finite. Narrower interval gives faster result.
%       In complex case real parts of LMB are compared to LB and UB.
%
%       Output results:
%       XV eigenvectors, ordered so that NORM(A*XV-B*XV*DIAG(LMB)) small
%       LMB eigenvalues in interval, sorted
%       IRESULT flag ABS(IRESULT) number of eigenvalues found
%       IRESULT =>0 successful termination, all eigenvalues in interval found
%       IRESULT < 0 not yet successful, there may be more eigenvalues. Try
%       again with a smaller interval!
%
%       Parameters that may be set, but have defaults:
%       SPD   true if pencil known to be symmetric pos definite
%       default false
%
%       TOLCONV   expected relative accuracy
%       default 100*eps machine precision
%
%       JMAX  maximum number of basis vectors. You need JMAX*N working space
%       so a small value may be justified on a small computer, otherwise
%       let it be the default value JMAX=100. Normally the algorithm stops
%       earlier when enough eigenvalues have converged.
%
%       MAXMUL number of Arnoldi runs tried. Must at least be as large
%       as maximum multiplicity of any eigenvalue. If a small value of
%       JMAX is given, many Arnoldi runs are necessary.
%       Default value is MAXMUL=N, which will be needed when all the
%       eigenvalues of the unit matrix are sought!
%
%       Algorithm description:
%       Uses Arnoldi with spectral transformation. The shift is chosen
%       at UB, LB or at a random point in the interval (LB,UB) when both
%       bounds are finite.
%       Number of steps J in the Arnoldi run depends on how many
%       eigenvalues there are in the interval, but stops at J=MIN(JMAX,N).
%       After a
%       stop, restart to find more Schur vectors in orthogonal complement to
%       all those already found. When no more eigenvalues are found in
%       LB < LMB <= UB, algorithm stops. For small values of JMAX, several
%       restarts may be needed before a certain eigenvalue has converged,
%       algorithm works for JMAX > #eigenvalues in interval + 1, but then
%       many restarts are needed. For large values of JMAX, which is the
%       preferred choice, MUL+1 runs are needed, where MUL is the maximum
%       multiplicity of an eigenvalue in the interval.
%         Works on nonsymmetric as well as symmetric pencils, but then accuracy
%       is approximately TOL*(Henrici departure from normality). The
%       parameter SPD is used only to choose between SYMAMD and COLAMD when
%       factorizing, the former being marginally better for symmetric matrices
%       close to the lower end of the spectrum.
%        case of trouble:
%       If convergence is too slow, try (in this order of priority)
%       1) a smaller interval LB,UB
%       2) a larger JMAX
%       3) a larger MAXMUL.
%         If factorization fails, try again with LB and UB finite.
%       Then shift is chosen at random and hopefully not at an eigenvalue.
%       If it fails again, check whether pencil is singular.
%         If it goes on forever, there may be too many eigenvalues in the
%       strip. Try with a small value MAXMUL=2 and see which eigenvalues you
%       get! Those you get are some of the evs, but a negative iresult tells
%       you that you have not gotten them all.
%         If memory overflows, try smaller JMAX.
%         Algorithm is designed for eigenvalues close to the real axis. If you
%       want those close to the imaginary axis, try A=i*A!
%         When SPD is true, shift is at LB so that advantage is taken of the
%       faster factorization for symmetric positive definite matrices.
%       No harm done but slower execution if LB above lowest eigenvalue.

%       A Ruhe 8-08-94, AN 8-23-94.
%       Copyright 1994-2003 The MathWorks, Inc.
%       $Revision: 1.9.4.2 $  $Date: 2004/01/16 20:06:39 $
cpustart=cputime;
n=size(A,1);
if nargin<5, spd=0; end;
if nargin<6, tolconv=100*eps; end;
if nargin<7, jmax=min(100,n); end;
if nargin<8, maxmul=n; end;

% Choose shift
if lb==-inf && ub==inf
  % No info on eigenvalue location, pick shift in the dark
  shift=rand(1);
elseif lb==-inf,
  shift=ub;
elseif ub==inf,
  shift=lb;
elseif spd,
  shift=lb;
else
  ranv=rand(2,1);
  shift=[lb ub]*ranv/sum(ranv);
end;

% Never more than n basis vectors!
jmax=min(jmax,n);

% Factorize and check if problem it not too singular
ntries=0;
maxtries=2;
while ntries<=maxtries

  C=A-shift*B;
  if spd,
    pm=symamd(C);
    [R,p]=chol(C(pm,pm));
    if p==0
      L=R';
      U=R;
      clear R;
    else
%      fprintf('Problem not symmetric positive definite\n');
      pm=colamd(C);
      [L,U]=lu(C(pm,pm));
    end
  else
    pm=colamd(C);
    [L,U]=lu(C(pm,pm));
  end

  % Check for singularity
  v=U\(L\rand(n,1));
  fact=norm(v,inf)*norm(C,inf);

  if fact>0.01/eps
    % Try another shift
    if lb==-inf && ub==inf
      % No info on eigenvalue location, pick shift in the dark
      shift=rand(1,1);
    elseif lb==-inf,
      if ub==0
        % No info here either
        shift=-rand(1);
      else
        shift=ub-abs(ub)*rand(1);
      end
    elseif ub==inf,
      if lb==0
        % No info here either
        shift=rand(1);
      else
        shift=lb+abs(lb)*rand(1);
      end
    else
      ranv=rand(2,1);
      shift=[lb ub]*ranv/sum(ranv);
    end
  else
    clear C;
    B=B(pm,pm);
    break;
  end

  ntries=ntries+1;
end

if ntries>maxtries
  error('PDE:sptarn:EigenvalueShiftNotFound',...
      'Suitable eigenvalue shift could not be found. Try a different range.')
end

% tol is tolerance for convergence
% tolspur tol to determine spurious vectors
% tolstab decides when eigenvalue appr is stabilized
tol=tolconv;
tolspur=100*tolconv;
tolstab=1e-5;
% check for convergence first after jf steps, then every js steps
% The larger n the cheaper is the test compared to an extra step
js=ceil(4000/n);
jf=10;
%
normhj=0;
%
% nt is total number of converged values, both inside and outside interval
% US is n*nt matrix of Schur vectors
% T is nt*nt upper triangular Schur form
nt=0;
US=[];
T=[];
%
% Starting vector
vstart=randn(n,1);
terminatealg=0;
% Finally, it is time to start
fprintf('\n')
for mul=1:maxmul
  % Starting vector orthogonalized against already converged
  v=[US pdegrmsc(vstart,US)];
  h=[T;zeros(1,nt)];
  convrun=0;
  % First testing point
  jt=min(nt+jf,jmax);
  for j=nt+1:jmax,
    r=U\(L\(B*v(:,j)));
    [vj1,hj]=pdegrmsc(r,v);
    h=[h hj(1:j)];
    normhj=max(normhj,norm(hj));
    % Test if linear dependence, signals decrease of band width or
    % convergence
    if hj(j+1) < tol*normhj,
      convrun=1;
      jt=j;
    else
      v=[v vj1];
    end;
    h=[h;zeros(1,j-1) hj(j+1)];

    % One vector added, is it time to test?
    if j==jt
      iv=nt+1:jt;
      [us,ts]=schur(h(iv,iv));
      [uc,tc]=rsf2csf(us,ts);
      lms=shift+1 ./diag(tc);
      sij=abs((h(j+1,j)/normhj)*us(j-nt,:))';

      % Test if it is time to stop
      convoutside=(lms<=lb|lms>ub) & sij<=tolstab;
      nonconvinside= lb<lms & lms<=ub & sij>tol & abs(us(1,:))'>tolspur;
      convrun= convrun | (any(convoutside) & ~any(nonconvinside));
% Report progress if wanted
   if any(nonconvinside),
       incinside=find(nonconvinside);
       iintr=incinside(1);
   else
       iintr=1;
   end;
    fprintf('              Basis=%3.0f,  Time=%7.2f,  New conv eig=%3.0f\n',j,cputime-cpustart,sum(sij<=tol));
%   fprintf(1,'%4.0f %7.2f %3.0f ',j, cputime-cpustart,sum(sij<=tol));
%   fprintf(1,'%12.5e +i%12.5e %10.3e \n',real(lms(iintr)),imag(lms(iintr)), sij(iintr));
% end report part
      jt=min(jt+js,jmax);
    end
    if convrun
      break;
    end
  end % for j=nt+1:jmax,

  % nc is number of converged eigenvalues above the first nonconverged along h
  nc=sum(cumprod(double(sij<=tol)));
% Report progress of sweep
fprintf('End of sweep: Basis=%3.0f,  Time=%7.2f,  New conv eig=%3.0f\n',j,cputime-cpustart,nc);
% end report progress
  if nc>0,
    T=[T h(1:nt,iv)*us(:,1:nc); zeros(nc,nt) ts(1:nc,1:nc)];
    US=[US v(:,iv)*us(:,1:nc)];
    nt=nt+nc;
    if nt>=jmax,
      terminatealg=1;
    end
  end
  newinside=lb<lms & lms<=ub;
  if nc>0 && any(newinside & sij<=tol),
    vstart=randn(n,1);
  elseif any(newinside),
    vstart=v(:,iv)*us(:,min(find(newinside)));
  else
    terminatealg=1;
  end
  if terminatealg
    break;
  end
end % for mul=1:maxmul

% Triangular matrix is complete. Get eigensolution!
%[s,dt]=eig(T,'nobalance');
[s,dt]=eig(T.*(abs(T)>tol*normhj),'nobalance');
ev=shift+1./diag(dt);

% Deliver eigenvalues in interval as result
inside=find(lb<ev & ev<=ub);
iresult=length(inside);
[lmb,ievsrt]=sort(ev(inside));
xv=US*s(:,inside(ievsrt));
if size(xv,2)>0
  xv(pm,:)=xv;
end

if ~terminatealg
  iresult=-iresult;
end

