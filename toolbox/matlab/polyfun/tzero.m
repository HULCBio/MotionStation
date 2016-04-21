function [z,gain] = tzero(a,b,c,d)
%TZERO  Transmission zeros of LTI systems.
% 
%    Z = TZERO(SYS) returns the transmission zeros of the LTI 
%    system SYS.
%
%    [Z,GAIN] = TZERO(SYS) also returns the transfer function 
%    gain if the system is SISO.
%   
%    Z = TZERO(A,B,C,D) works directly on the state space matrices
%    and returns the transmission zeros of the state-space system:   
%             .
%             x = Ax + Bu     or   x[n+1] = Ax[n] + Bu[n]
%             y = Cx + Du           y[n]  = Cx[n] + Du[n]
%
%    See also PZMAP, POLE, EIG.

%   Clay M. Thompson  7-23-90
%       Revised: A.Potvin 6-1-94, P.Gahinet 5-15-96
%   Copyright 1984-2004 The MathWorks, Inc. 
%   $Revision: 1.35.4.2 $  $Date: 2004/01/24 09:22:49 $

% Extracts from the system matrix of a state-space system [ A B C D ] a regular
% pencil [ Lambda*Bf - Af ] which has the NU Invariant Zeros of the system as
% Generalized Eigenvalues.
%  
%  Reference: Adapted from "Computation of Zeros of Linear Multivariable
%             Systems", A. Emami-Naeini, and P. Van Dooren; Automatica 
%             Vol. 18, No. 4, pp. 415-430, 1982.

% The transmission zero calculation can be tested by checking that the
% matrix: [A B;C D]-lambda*[I 0; 0 0] is rank deficient, where lambda
% is an element of Z.

ni = nargin;
error(nargchk(4,4,ni));
[msg,a,b,c,d]=abcdchk(a,b,c,d); error(msg);
gain = [];

if isempty(b) && isempty(c),
   z = zeros(0,1);
   gain = d; 
   return
end

% Epsilon used for transmission zero calculation.
Zeps = 10*eps*norm(a,'fro');

nn = size(a,1);
pp = size(c,1);
mm = size(b,2);
issiso = (mm==1 & pp==1);

% Construct the Compound Matrix [ B A ] of Dimension (N+P)x(M+N) 
%                               [ D C ]
bf = [b a; d c];

% Reduce this system to one with the same invariant zeros and with
% D(*) full rank MU (The Normal Rank of the original system)
[bf,mu,nu] = tzreduce(bf,mm,nn,pp,Zeps,pp,0);
Rank = mu;
if nu==0, 
   z = zeros(0,1);
else
   % Pretranspose the system
   mnu = mm+nu;
   numu = nu+mu;
   af = zeros(mnu,numu);
   af(mnu:-1:1,numu:-1:1) = bf(1:numu,1:mnu).';

   if mu~=mm,
      pp = mm;
      nn = nu;
      mm = mu;

      % Reduce the system to one with the same invariant zeros and with
      % D(*) square invertible

      [af,mu,nu] = tzreduce(af,mm,nn,pp,Zeps,pp-mm,mm);
      mnu = mm+nu;
   end

   if nu==0,
      z = zeros(0,1);
   else
      % Perform a unitary transformation on the columns of [ sI-A B ]
      %                          [ sBf-Af X ]              [   -C D ]
      % in order to reduce it to [   0    Y ] with Y & Bf square invertible
      bf(1:nu,1:mnu) = [zeros(nu,mm),eye(nu)];
      if Rank~=0,
         nu1 = nu+1;
         i1 = nu+mu;
         i0 = mm;
         for i=1:mm
            i0  = i0-1;
            cols = i0 + (1:nu1);
            [dummy,s,zero] = housh(af(i1,cols)',nu1,Zeps);
%REVISIT: temp. fix
%            af(1:i1,cols) = af(1:i1,cols)*(eye(nu1)-s*dummy*dummy');
%            bf(1:nu,cols) = bf(1:nu,cols)*(eye(nu1)-s*dummy*dummy');
            af(1:i1,cols) = af(1:i1,cols)-s*(af(1:i1,cols)*dummy)*dummy';
            bf(1:nu,cols) = bf(1:nu,cols)-s*(bf(1:nu,cols)*dummy)*dummy';
            i1 = i1-1;
         end % for
      end % if Rank~=0

      % Solve Generalized zeros of sBF - AF
      z = eig(af(1:nu,1:nu),bf(1:nu,1:nu));
   end % if nu==0
end

% Compute transfer function gain if necessary
if (nargout==2) && issiso,  % (mm*pp==1),
   if nu==nn,
      gain=bf(nu+1,1);
   else
      gain=bf(nu+1,1)*prod(diag(bf(nu+2:nn+1,nu+2:nn+1)));
   end
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function [abcd,mu,nu] = tzreduce(abcd,m,n,p,Zeps,ro,sigma)
%TZREDUCE Utility function for TZERO.
%   [ABCD.MU,NU] = TZREDUCE(ABCD,M,N,P,Zeps,RO,SIGMA) Extracts
%       the reduced system from the input system matrix 
%   such that the new system D matrix has full row rank.

%   Clay M. Thompson  7-23-90

%  Extracts from the (N+P)x(M+N) system [ B A ],  a (NU+MU)x(M+NU) 'reduced' 
%         [ B' A' ]                     [ D C ]
%  system [ D' C' ] having the same transmission zeros but with D' Full Row 
%  Rank.  The system [ A' B' C' D' ] overwrites the old system.
%
% Reference: Adapted from "Computation of Zeros of Linear Multivariable
%            Systems", A. Emami-Naeini, and P. Van Dooren; Automatica
%            Vol. 18, No. 4, pp. 415-430, 1982.

% Initialize
Sum2 = zeros(1,max(p,m));
mu = p;
nu = n;
while mu~=0,
   ro1 = ro;
   mnu = m+nu;
   numu = nu+mu;

   if m~=0,
      ro1 = ro1+1;
      irow = nu;

      % Compress rows of D(*).  First exploit triangular shape
      for icol=1:sigma-1
         rows = irow + (1:ro1);
         [dummy,s,zero] = housh(abcd(rows,icol),1,Zeps);
% REVISIT: temp. fix
%         abcd(rows,icol:mnu) = (eye(ro1)-s*dummy*dummy')*abcd(rows,icol:mnu);
         abcd(rows,icol:mnu) = abcd(rows,icol:mnu)-s*dummy*(dummy'*abcd(rows,icol:mnu));
         irow = irow+1;
      end

      % Continue householder with pivoting
      if sigma==0,
         sigma = 1;
         ro1 = ro1-1;
      end

      if sigma~=m,
         Sum2(sigma:m) = sum(abcd(irow+1:irow+ro1,sigma:m).*conj(abcd(irow+1:irow+ro1,sigma:m)));
      end

      for icol=sigma:m;
         % Pivot if necessary
         if icol~=m,
            Rows = 1:numu;
            [dum,ibar] = max(Sum2(icol:m));
            ibar = ibar+icol-1;
            if ibar~=icol,
               Sum2(ibar) = Sum2(icol); 
               Sum2(icol) = dum;
               dum = abcd(Rows,icol);
               abcd(Rows,icol)=abcd(Rows,ibar);
               abcd(Rows,ibar)=dum;
            end
         end

         % Perform Householder transformation
         [dummy,s,zero] = housh(abcd(irow+1:irow+ro1,icol),1,Zeps);
         if zero,
            break
         end
         if ro1==1,
            return
         end
% REVISIT: temp. fix
         abcd(irow+1:irow+ro1,icol:mnu) = abcd(irow+1:irow+ro1,icol:mnu) - ...
                             s*dummy*(dummy'*abcd(irow+1:irow+ro1,icol:mnu));
         irow = irow+1;
         ro1 = ro1-1;
         Sum2(icol:m) = Sum2(icol:m) - abcd(irow,icol:m) .* conj(abcd(irow,icol:m));
      end % for
   end % if
   tau = ro1;
   sigma = mu-tau;

   % Compress the columns of C(*)
   if (nu<=0),
      mu = sigma; 
      nu = 0;
      return
   end

   i1 = nu+sigma;
   mm1 = m+1;
   n1 = nu;
   if tau~=1,
      Sum2(1:tau) = sum((abcd(i1+1:i1+tau,mm1:mnu).*conj(abcd(i1+1:i1+tau,mm1:mnu)))');
   end

   for ro1=1:tau;
      ro = ro1-1;
      i = tau-ro;
      i2 = i+i1;

      % Pivot if necessary
      if i~=1,
         [dum,ibar] = max(Sum2(1:i));
         if ibar~=i,
            Sum2(ibar) = Sum2(i); Sum2(i) = dum;
            dum = abcd(i2,mm1:mnu);
            abcd(i2,mm1:mnu) = abcd(ibar+i1,mm1:mnu);
            abcd(ibar+i1,mm1:mnu) = dum;
         end
      end

      % Perform Householder Transformation 
      cols = m + (1:n1);
      [dummy,s,zero] = housh(abcd(i2,cols)',n1,Zeps);
      if zero,
         break
      end
      if n1~=1
% REVISIT: temp. fix
%         abcd(1:i2,cols) = abcd(1:i2,cols)*(eye(n1)-s*dummy*dummy');
         abcd(1:i2,cols) = abcd(1:i2,cols)-s*(abcd(1:i2,cols)*dummy)*dummy';
         mn1 = m+n1;
%         abcd(1:n1,1:mn1) = (eye(n1)-s*dummy*dummy')*abcd(1:n1,1:mn1);
         abcd(1:n1,1:mn1) = abcd(1:n1,1:mn1)-s*dummy*(dummy'*abcd(1:n1,1:mn1));
         Sum2(1:i) = Sum2(1:i)-(abcd(i1+1:i1+i,mn1) .* conj(abcd(i1+1:i1+i,mn1)))';
         mnu = mnu-1;
      end
      n1 = n1-1;
   end % for

   if ~zero,
      ro = tau;
   end
   nu = nu-ro;
   mu = sigma+ro;
  
   if ro==0,
      return
   end
end % while

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [u,s,zero] = housh(u,j,heps)
%HOUSH  Construct a householder transformation H=I-s*UU'.  Used in TZERO.
%   [U,S,ZERO] = HOUSH(U,J,Heps)

%   Clay M. Thompson  7-23-90

%  Constructs a Householder transformation H=I-s*UU' that 'mirrors' a 
%  vector u to the Jth unit vector.  If NORM(U)<Eps then Zero=1 [True]
%
% Reference: Adapted from "Computation of Zeros of Linear Multivariable
%            Systems", A. Emami-Naeini, and P. Van Dooren; Automatica
%            Vol. 18, No. 4, pp. 415-430, 1982.

s = sum(u.*conj(u));
alfa = sqrt(s);
if (alfa<=heps), 
   zero=1; 
   return
end
zero=0;

% Transform is I-2vv'/(v'v) where v = u+beta*ej and beta = (uj/|uj|)*norm(u)
beta = (sign(u(j))+(u(j)==0)) * alfa;
s = 1./(s+real(conj(beta)*u(j)));   % u'*u+conj(beta)*uj
u(j) = u(j)+beta;
