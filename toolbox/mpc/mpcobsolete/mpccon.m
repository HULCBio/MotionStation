function controller = mpccon(model,yweight,uweight,no_moves,horizon)
%MPCCON	Calculate MPC controller gains for unconstrained case.
%	Kmpc = mpccon(model,ywt,uwt,M,P)
% MPCCON uses a step-response model of the process.
%
% Inputs:
%  model   : Step response coefficient matrix of model.
%  ywt,uwt : matrices of constant or time-varying weights.
%            If the trajectory is too short, they are kept constant
%            for the remaining time steps.
%  M       : number of input moves and blocking specification.  If
%            M contains only one element it is the input horizon
%            length.  If M contains more than one element
%            then each element specifies blocking intervals.
%  P       : output (prediction) horizon length.  P = Inf indicates the
%	     infinite horizon.
%
% Output:
%  Kmpc	   : Controller gain matrix
%
% See also CMPC, MPCCL, MPCSIM.

%       Copyright 1994-2003 The MathWorks, Inc.
%       $Revision: 1.1.6.2 $

if (nargin==0)
   disp('usage: Kmpc = mpccon(model,ywt,uwt,M,P)');
   return;
end;
%
% Error checking and defaults:

if nargin < 1 | nargin > 5
   error('Incorrect number of input arguments!')
end

[nny,nu] = size(model);    	% nu = number of manipulated variables
ny = model(nny-1,1);     	% ny = number of output variables
n = (nny-2-ny)/ny;        	% n  = truncation length for step response
nstep = n;

if nargin >= 2
   if isempty(yweight)
      yweight=ones(1,ny);
      nywt=1;
   else
      [nywt,ncols]=size(yweight);
      if ncols ~= ny
         error('# columns in YWEIGHT must equal # outputs in MODEL')
      end
   end
else
   yweight=ones(1,ny);
   nywt=1;
end

if nargin >= 3
   if isempty(uweight)
      uweight=zeros(1,nu);
      nuwt=1;
   else
      [nuwt,ncols]=size(uweight);
      if ncols ~= nu
         error('# columns in UWEIGHT must equal # inputs in MODEL')
      end
   end
else
   uweight=zeros(1,nu);
   nuwt=1;
end

if nargin >= 5
   if isempty(horizon)
      p=1;
   else
      if horizon >= 1
         p=horizon;
      else
         error('HORIZON was zero or negative.')
      end
   end
else
   p=1;
end

if horizon == Inf,
   p = sum(no_moves) + nstep + 2;
end

pny = p*ny;

if nargin >= 4
   if isempty(no_moves)
      moves=ones(1,p);    % moves = duration of each block
      m=p;                % m = number of "blocks".  Defaults to p.
   else
      [rows,m]=size(no_moves);
      if rows ~= 1
         error('NO_MOVES must be a row vector')
      elseif any(no_moves(1,:) < 1)
         error('An element of NO_MOVES was zero or negative')
      else
         if m == 1    % If true, interpret NO_MOVES in normal DMC fashion
            m=no_moves;
            if m > p
               disp('WARNING:  NO_MOVES > HORIZON.')
               disp('          Will use NO_MOVES = HORIZON.')
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
                  disp('WARNING:  sum(NO_MOVES) < HORIZON.')
                  disp('          Will extend to HORIZON.')
               end
            else
               disp('WARNING:  sum(no_moves) > horizon.')
               disp('          Moves will be truncated at horizon.')
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
if (n < (p+1))
   nny = nny-ny-2;
   nout = model(nny+1:nny+ny,1);
   intm = ones(ny,1)-nout;
   k = nny;   kx = nny-ny+1;
   int = intm*ones(1,nu);
   for ib = n+1:p+1
       model(k+1:k+ny,:) = model(kx:k,:) + int.*(model(kx:k,:) ...
                           - model(kx-ny:kx-1,:));
       k = k+ny;  kx = kx+ny;
   end;
   nny = k;   n = p+1;
end;
if nuwt > m
   disp('WARNING:  extra rows in UWEIGHT ignored')
end
if nywt > p
   disp('WARNING:  extra rows in YWEIGHT ignored')
end

% +++ Set up the Su matrix +++

mnu=m*nu;     % total number of columns in final Su matrix.
Su = [model(1:pny,:) zeros(pny,mnu-nu)];  % This fills the first nu columns
                                              % and is all we need if m = 1.

% If number of moves > 1, fill the remaining columns of Su,
% doing "blocking" at the same time.

if m > 1
   k = nu;
   moves=cumsum(moves);
   for i = 2:m
      row0=moves(i-1)*ny;
      Su(row0+1:pny,k+1:k+nu)=model(1:pny-row0,:);
      k=k+nu;
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
% X is of dimensions (mnu by pny) and is the desired controller gain for the
% entire prediction horizon.  Finally, X is truncated to give the gain for a
% single sampling period.

ywt=[]; uwt=[];
for i=1:p
   if i <= nywt
      ywt=[ywt;yweight(i,:)'];         		% Creates a vector of y weights,
   elseif i==p & horizon == Inf,		% length pny, repeating the last
      ywt=[ywt;100*max([yweight;zeros(1,ny)])'];  % row of yweight if necessary.
   elseif i==p-1 & horizon == Inf,
      ywt=[ywt;max([yweight;zeros(1,ny)])'.*(1+intm*100)];
   else
      ywt=[ywt;yweight(nywt,:)'];
   end
end

for i=1:m
   if i <= nuwt
      uwt=[uwt;uweight(i,:)'];         % Creates a vector of u weights,
   else                                % length mnu, repeating the last
      uwt=[uwt;uweight(nuwt,:)'];      % row of uweight if necessary.
   end
end

X = [diag(ywt)*Su;diag(uwt)]\[diag(ywt);zeros(mnu,pny)];   % This is X=A\B.
controller = X(1:nu,1:pny);                                % Truncate to one
                                                           % sampling period

%  end of file MPCCON.M