function [a,b,c,d] = tfm2ss(varargin)
%TFM2SS State-space realization of transfer function matrix.
%
% [SS_] = TFM2SS(TFM) or
% [A,B,C,D] = TFM2SS(NUM,DEN,M,N) produces a state space Block Controller
% (or Observer) form of a Proper Rational Transfer Function Matrix (MIMO)
%
%                   |N11(s) N12(s) .... N1m(s)|
%     TFM  = 1/d(s) | ........................| = mksys(num,den,m,n,'tfm');
%                   |Nn1(s) ........... Nnm(s)|
%
%     NUM : a matrix whose rows are the coefficients of the numerators
%           of the TF matrix entries (ie : n11-->row1, n21-->row2, ..etc.).
%     DEN : a row vector contains the coefficients of Characteristic
%           polynomial d(s) (with the highest degree: r).
%     M   : no. of system inputs.
%     N   : no. of system outputs.
%
%     Note: The resulting A matrix will have "r x min(m,n)" states
%           which is nonminimal. The regular state-space can be recovered
%           "branch".

% R. Y. Chiang & M. G. Safonov 10/22/88
% Copyright 1988-2004 The MathWorks, Inc.
%       $Revision: 1.9.4.3 $
% All Rights Reserved.
%---------------------------------------------------------------------

% Handle lti with fall through to SS(SYS)
if isa(varargin{1},'lti'),
   warning('TFM2SS is obsolete. For LTI objects, use SS(SYS) instead.')
   a=ss(varargin{1});
   return
end

nag1=nargin;
[emsg,nag1,xsflag,Ts,num,den,m,n]=mkargs5x('tfm',varargin); error(emsg);

%
% ------ Convert to Block Observer Form
%        (if there are more inputs than outputs):
%
m0 = m; n0 = n;
if m0 > n0
    m = n0; n = m0;
end
%
num = num./den(1);
den = den./den(1);
[rd,cd] = size(den);
rm = (cd-1) * m;
[rn,cn] = size(num);
%
if cn < cd
   num = [zeros(rn,(cd-cn)) num];
end
%
% ------ State Space of a Constant :
%
if cd == 1
   a = []; b = 0; c = 0; d = num;
   return
end
%
% ------ D matrix :
%
d = zeros(n,m);
d(:)  = num(:,1);
%
% ------ Proper Rational TF matrix --> Strictly proper :
%
for v = 1:m*n
    nnum(v,:) = num(v,:) - den * num(v,1);
end
%
% ------ A matrix :
%
for i = 1:cd-1
    a1(1:m,i*m-(m-1):i*m) = -den(i+1) * eye(m);
  end
if rm == m
    a = a1;
else
    a = [a1;eye(rm-m) zeros(rm-m,m)];
end
%
% ------ B matrix :
%
if rm == m
    b = eye(m);
else
    b = [eye(m);zeros(rm-m,m)];
end
%
% ------ C matrix :
%
u = 0.;
for s = 1:cd-1
    for p = 1 : m
        u = u+1;
        c(:,u) = nnum(p*n-(n-1):p*n,s+1);
    end
end
%
% ------ Convert to Block Observer Form
%        (if there are more inputs than outputs):
%
if m0 > n0
   a = a'; btemp = b; b = c'; c = btemp'; d = d';
end
%
if xsflag
   a = mksys(a,b,c,d,Ts);
end
%
% ------ End of TFM2SS.M ---- RYC/MGS %