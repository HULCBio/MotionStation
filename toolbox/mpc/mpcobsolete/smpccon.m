function Ks = smpccon(imod,ywt,uwt,no_moves,horizon)

%SMPCCON Calculate MPC controller gains for unconstrained case.
% 	Ks = smpccon(imod,ywt,uwt,M,P)
% SMPCCON Uses a state-space model of the process.
%
% Inputs:
%  imod   : Model of plant to be used as state estimator and for gain
%           for gain calculation (mod form).
%  ywt,uwt: matrices of constant or time-varying weights.
%           If the trajectory is too short, it is kept constant
%           for the remaining time steps.  For 'shifted' and
%           'blocked' data.
%
%            |yw1(1) . . . ywny(1)|           |uw1(1) . . . uwnu(1)|
%  ywt   =   |  .            .    |    uwt =  |  .            .    |
%            |yw1(P) . . . ywny(P)|           |uw1(M) . . . uwnu(M)|
%
%        where nu, ny are number of man. vars. and outputs respectively
%  M    :number of input moves and blocking specification.  If
%        M contains only one element it is the input horizon
%        length.  If M contains more than one element
%        then each element specifies blocking intervals.
%  P    :output (prediction) horizon length
%
% Output:
%   Ks  :Controller gain matrix = [Kr, Kx, Kv].
%
% See also SCMPC, SMPCCL, SMPCSIM.

%       Copyright 1994-2003 The MathWorks, Inc.
%       $Revision: 1.1.6.2 $

% Error checking and defaults:

if nargin == 0
   disp('USAGE:  Ks = smpccon(imod,ywt,uwt,M,P)')
   return
elseif nargin < 1 | nargin > 5
   error('Incorrect number of input arguments!')
end

[phii,gami,ci,di,minfoi]=mod2ss(imod);
ni=minfoi(2);
nui=minfoi(3);
nvi=minfoi(4);
mi=nui+nvi;
nwi=minfoi(5);
if nwi > 0              % Strip off unmeasured disturbance
   gami=gami(:,1:mi);   % model if it exists.
   di=di(:,1:mi);
end
nymi=minfoi(6);
nyui=minfoi(7);
nyi=nymi+nyui;

if any(any(di ~= 0))
   error(['First nu+nv=',int2str(nui+nvi),' columns of D matrix in IMOD',...
          ' must be zero.'])
end

if nargin >= 2
   if isempty(ywt)
      ywt=ones(1,nyi);
      nywt=1;
   else
      [nywt,ncols]=size(ywt);
      if ncols ~= nyi
         error('# columns in YWT must equal # outputs in IMOD')
      end
   end
else
   ywt=ones(1,nyi);
   nywt=1;
end

if nargin >= 3
   if isempty(uwt)
      uwt=zeros(1,nui);
      nuwt=1;
   else
      [nuwt,ncols]=size(uwt);
      if ncols ~= nui
         error('# columns in UWT must equal # man. vars. in IMOD.')
      end
   end
else
   uwt=zeros(1,nui);
   nuwt=1;
end

if nargin >= 5
   if isempty(horizon)
      p=1;
   else
      if horizon >= 1
         p=horizon;
         if horizon > 50
            disp('WARNING:  horizon > 50, unusually large.')
            disp('          May run out of memory')
         end
      else
         error('HORIZON was zero or negative.')
      end
   end
else
   p=1;
end

pny = p*nyi;

if nargin >= 4
   if isempty(no_moves)
      moves=ones(1,p);    % moves = duration of each block
      m=p;                % m = number of "blocks".  Defaults to p.
   else
      [rows,m]=size(no_moves);
      if rows ~= 1
         error('M must be a row vector')
      elseif any(no_moves(1,:) < 1)
         error('An element of M was zero or negative')
      else
         if m == 1    % If true, interpret M in normal DMC fashion
            m=no_moves;
            if m > p
               disp('WARNING:  M > P.')
               disp('          Will use M = P.')
               m=p;
               moves=ones(1,m);
            elseif m == p
               moves=ones(1,m);
            else
               moves=[ones(1,m) p-m];
            end
         else         % Otherwise, treat NO_MOVES as a set of blocking factors
            moves=no_moves;
            ichk=find(cumsum(moves) > p);
            if isempty(ichk)
               if sum(moves) < p
                  moves=[moves p-sum(moves)];
               end
            else
               m=ichk(1);
               moves=moves(1,1:m);
            end
         end
      end
   end
else
   moves=ones(1,p);
   m=p;
end

if nuwt > m
   disp('WARNING:  extra rows in UWT ignored')
end
if nywt > p
   disp('WARNING:  extra rows in YWT ignored')
end

% ++++ Beginning of controller design calculations. ++++

% The following index vectors are used to pick out certain columns
% or rows in the state-space matrices.

iu=[1:nui];                 % columns of gami, gamp, di, dp related to delta u.
iv=[nui+1:nui+nvi];         % points to columns for meas. dist. in gamma.

% +++ Calculate the basic projection matrices +++

pny=nyi*p;              % Total # of rows in the final projection matrices.
mnu=m*nui;             % Total number of columns in final Su matrix.

% +++ Augment the internal model state with the outputs.

[PHI,GAM,C,D,N]=mpcaugss(phii,gami,ci,di);

Cphi=C*PHI;
Sx=[      Cphi
    zeros(pny-nyi,N)];
Su=[    C*GAM(:,iu)
    zeros(pny-nyi,nui)];
if nvi > 0
   Sv0=[ C*GAM(:,iv)
        zeros(pny-nyi,nvi)];
else
   Sv0=[];
end

r1=nyi+1;
r2=2*nyi;
eyep=eye(nyi); % eyep is a matrix containing P identity matrices (dimension nyi)
               % stacked one on top of the other.
for i=2:p
   if nvi > 0
      Sv0(r1:r2,:)=Cphi*GAM(:,iv);
   end
   Su(r1:r2,:)=Cphi*GAM(:,iu);
   Cphi=Cphi*PHI;
   Sx(r1:r2,:)=Cphi;
   r1=r1+nyi;
   r2=r2+nyi;
   eyep=[eyep;eye(nyi)];
end

% If number of moves > 1, fill the remaining columns of Su,
% doing "blocking" at the same time.

if m > 1
   k = nui;
   moves=cumsum(moves);
   for i = 2:m
      row0=moves(i-1)*nyi;
      Su(row0+1:pny,k+1:k+nui)=Su(1:pny-row0,1:nui);
      k=k+nui;
   end
end

% ++++ Calculate controller gain ++++

% The controller gain is computed using the following matrices:
%
%       [ GAMMA*Su ]                 [ GAMMA ]
%   A = |          |      ;      B = |       |
%       [  LAMBDA  ]                 [   0   ]
%
% GAMMA is (pny by pny)  Lambda is (mnu by mnu)   Su is (pny by mnu).
% X=A\B corresponds to left division : the solution to A*X=B : X=inv(A'*A)*A'*B
% X is of dimension (mnu by pny) and is the desired controller gain for the
% entire prediction horizon.  Finally, X is truncated to give the gain for a
% single sampling period.

ywts=[];
for i=1:p
   if i <= nywt
      ywts=[ywts;ywt(i,:)'];         % Creates a vector of y weights,
   else                              % length pny, repeating the last
      ywts=[ywts;ywt(nywt,:)'];      % row of ywt if necessary.
   end
end

uwts=[];
for i=1:m
   if i <= nuwt
      uwts=[uwts;uwt(i,:)'];         % Creates a vector of u weights,
   else                              % length mnu, repeating the last
      uwts=[uwts;uwt(nuwt,:)'];      % row of uweight if necessary.
   end
end
uwts=uwts+10*sqrt(eps);  % for numerical stability

X = [diag(ywts)*Su;diag(uwts)]\[diag(ywts);zeros(mnu,pny)];   % This is X=A\B.

% The first nui rows and pny columns of X are Kmpc.

Ks=X(1:nui,1:pny)*[eyep, -Sx, -Sv0];