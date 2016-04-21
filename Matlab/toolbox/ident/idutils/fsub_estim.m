function [a,b,c,d,x0,V0,E,K,S] = fsub_estim(we,ye,ue,n,q,mode,W,E,K);
% function [a,b,c,d,x0,V0,E,K] = fsub_estim(w,y,u,n,q,mode,W,E,K);
%
% Frequency domain subspace based estimation algorithm
%  
% Discrete time state-space models 
%  
%  Y_k = G_k U_k + V_k
%  
%  w_k X_k = A X_k + B U_k
%      Y_k = C X_k + D U_k + V_k
%
%  Input: 
%    w = frequencies (normalized  in interval [0-pi])
%    y = outputs (N x p)
%    u = inputs  (N x m)
%    n = model order
%    q = auxiliary model order (number of block rows)
%    mode.x0 = 'estim' Initial state x0 is estimated
%            = 'noestim' x0 is not estimated
%            = 'auto'    default 
%    mode.alg = 'proj' - unweighted projection algorithm
%             = 'iv' - iv based (not functional)
%             = 'wproj' - weighted projection algorithm 
%                         to provide asymptotically unbiased estimates
%             = 'auto' - default
%  		assuming white noise (OE case).
%    mode.stab = 'stable' - force stability
%              = 'none'   - stability not enforced
%              = 'auto'   - default 
%    mode.Aest = 'ls'     - Least squares solution for A (Kungs method)
%              = 'tls'    - Total least squares solution for A
%    mode.nk   =  nk      - vector of length #inputs. If element #i
%              is zero then no direct term is estmted from input #i. If
%              element #i is 1 then a direct term is estimated.
%    W         = frequency weights
%  Output:
%    a,b,c,d = state-space model
%    x0      = 'Frequency domain' Initial State
%    V0      = Normalized norm of least-squares residuals

% Copyright 2002-2003 The MathWorks, Inc.
%   $Revision: 1.3.4.1 $  $Date: 2004/04/10 23:18:27 $

% Size requirements:
%  
%      N_eff >= n + q*m_eff
% where N_eff = 2*times complex data and 1*times real data
% and  M_eff = m if no initial condition is estimated 
%            = m+1 if initial condition is estimated
%
% A sligthly conservative bound is then 
%  2N - 2 >= n + q(m+1) 

S=[];
realflag = 1;
try
    realflag = mode.realflag;
end

% Constants
PINVTOL = 1e-10;
KREGUL =  1e-10;

if nargin==0,
    disp('usage: [a,b,c,d,x0,V0,E,K] = fsub(w,y,u,n,q,mode,W,E,K);');
    return;
end  


if nargin<6,   % Fill in with defaults;
    mode.x0 = 'auto';
    mode.stab = 'auto';
    mode.alg = 'auto';
    mode.nk = 1;
    mode.Aest = 'auto';
    W =[];      
end

if ~isfield(mode,'x0'), 
    mode.x0 = 'auto';
end

if ~isfield(mode,'stab'), 
    mode.stab = 'auto';
end

if ~isfield(mode,'alg'), 
    mode.alg = 'auto';
end
if ~isfield(mode,'nk'), 
    mode.nk = 1;
end
if ~isfield(mode,'Aest'), 
    mode.Aest = 'auto';
end

if nargin<4,
    error('Too few input arguments');
end


switch lower(mode.x0)
    case {'auto', 'estim'}
        estx0 = 1;
        %  disp('X0 is estimated');
    case {'noestim'}
        estx0 = 0;
    otherwise
        error('Not a valid fsub_estim mode.x0 choice');
end


switch lower(mode.alg)
    case {'proj', 'auto'}
        wproj = 0;
        % case {'wproj', 'auto'}
    case {'wproj'}
        wproj = 1;
    case {'iv'}
        error('Not a valid fsub_estim algorithm choice');
    otherwise
        error('Not a valid fsub_estim mode.alg choice');
end

switch lower(mode.stab)
    case {'auto', 'none'}
        stab = 0;
    case {'stable'}
        stab = 1;
    otherwise
        error('Not a valid fsub_estim mode.stab choice');
end



if ~iscell(we),
    we = {we};
    ye = {ye};
    ue = {ue};
end

nexp = length(we);

nk = mode.nk(:);

y = [];
u = [];
w = [];
nkbup = nk;
for kexp = 1:nexp,
    y = [y; ye{kexp}];
    w = [w; we{kexp}];
    if estx0,
        tmp = zeros(length(we{kexp}),nexp);
        tmp(:,kexp) = exp(i*we{kexp}); 
        u = [u; [ue{kexp} tmp] ];
        nk = [nk; 1];
        
    else
        u = [u; ue{kexp} ];
    end
end

if check_inpidf(u,w,n);
else
    warning(['Information contents in input data do not support' ...
            ' estimation of X0. X0 will be set to zero.']);
    estx0 = 0;
    u = [];
    for kexp = 1:nexp,
        u = [u; ue{kexp} ];
    end
    nk = nkbup;
end



if ~isempty(W),
    if ~iscell(W),
        W = {W};
    end
    Ww = [];
    for kexp = 1:nexp,
        Ww = [Ww; W{kexp}];
    end
    Wd = spdiags(Ww,0,length(Ww),length(Ww));
    u = Wd*u;
    y = Wd*y;
    clear W Wd Ww
end


% Consistency check for data
%N = length(w);
% if w>2*pi | w<-2*pi, 
%     disp('Warning: frequency data outside [-2 pi, 2 pi]');
% end
if ~isreal(w), error('Frequencies cannot be complex'); end;

if max(w)>pi, 
    warning(['Frequencies above the Nyquist frequency are redundant and are', ...
            ' removed']);
    idx = find(w<=pi);
    w = w(idx);
    u = u(idx,:);
    y = y(idx,:);
end

if max(w)<0, %%LL careful for complex models TMC comm
    warning(['Frequencies below zero are redundant and are', ...
            ' removed']);
    idx = find(w>=0);
    w = w(idx);
    u = u(idx,:);
    y = y(idx,:);
end
N = length(w);
[dum,m] = size(u);
if dum~=N, error('Size inconsistency for U'); end;
[dum,p] = size(y);
if dum~=N, error('Size inconsistency for Y'); end;
if q<n+1, error('q must be larger than n+1'); end;

% Check number of data points (is two samples conservative if
% only complex data)
if 2*N-2 < n + q*m, 
    error('Too few frequency points (2*N-2 >= n + q*m)'); 
end;


if length(nk)~=m,
    error('nk must be #inputs long');
end
if ~all((nk==0) | (nk==1)), 
    error('nk can only have elements 0 and 1');
end

nestD = sum(nk==0);

%plot(w,abs(y));

if nargin<8, % Must calculate QR and SVD
    
    Y = zeros(q*p,N);
    Y(1:p,:) = y.';
    F = spdiags(exp(i*w),0,N,N);
    for k=1:q-1;
        Y(k*p+1:(k+1)*p,:) = Y((k-1)*p+1:k*p,:)*F;
    end;
    
    U = zeros(q*m,N);
    U(1:m,:) = u.';
    for k=1:q-1;
        U(k*m+1:(k+1)*m,:) = U((k-1)*m+1:k*m,:)*F;
    end;
    
    if wproj,
        %    disp('Wproj selected'); 
        Fn = kron(spdiags(exp(i*w),0,N,N),speye(p));
        Un = sparse(q*p,N*p);
        Un(1:p,:) = kron(sparse(ones(1,N)),speye(p));
        for k=1:q-1;
            Un(k*p+1:(k+1)*p,:) = Un((k-1)*p+1:k*p,:)*Fn;
        end;
        %  disp('Building K');
        
        % find diagonal of PiPerp
        UUinv = mypinv(full(U*U'),PINVTOL); %Guard against singular case.
        
        dpipsq = zeros(N,1);
        for k=1:N,
            dpipsq(k) = sqrt(1-U(:,k)'*UUinv*U(:,k));
        end
        
        % Directly find desired square root
        lldum =full(Un *  blockdiag(kron(dpipsq,eye(p))))';
        if realflag
            lldum = real(lldum);
        end
        [vk,sk,uk] =  svd(lldum,0);
        clear Un;
        % regularize
        sk = diag(sk);
        sk = sk+ones(q*p,1)*sk(1)*KREGUL;
        K = uk*diag(sk);
        Kinv = diag(sk.^(-1) ) * uk';
        
        %    if ~isempty(W),  
        %      KK = full(real( Un * blockdiag(kron(dpip,eye(p))) * blockdiag(W) * Un' ));
        %    else 
        %      KK = full(real( Un * blockdiag(kron(dpip,eye(p))) * Un' ));
        %    end;
        
        % $$$     [vk,sk,uk] = svd(real(full(KK)).',0);
        % $$$     %  semilogy(diag(sk)); disp('Press a key'); pause; 
        % $$$     %   K = real(sqrtm(KK));
        % $$$     sk = diag(sk);
        % $$$     sk = sk + sk(1)*ones(j,1)*KREGUL;
        % $$$     K = uk*diag(sk) ;
        % $$$     Kinv = diag( sk.^(-1) )* uk';
    else
        K = eye(q*p);
        Kinv = K;
    end
    %  disp('QR-factorization');
    if realflag
        H = [real(U) imag(U);real(Y) imag(Y)];
    else
        H = [U;Y];
    end
    clear U Y;
    R = triu(qr(full(H).')).';
    clear H;
    [rr,rc] = size(R);
    r22end = min(rc,p*q+m*q);
    R22 = R(m*q+1:end,m*q+1:r22end); 
    [V,S,E]=svd((Kinv*R22).',0);
    % disp(['Rank R22 = ' num2str(rank(R22))]);
    %semilogy(diag(S),'+');title('Singular values');pause(0.001)
else
    if q*p ~= size(K,2) | q*p ~= size(E,1) ,
        error('Sizes of supplied K and/or E are incompatible with q');
    end
end
EE = K*E(:,1:n);

% Use Kungs method
c  = EE(1:p,:);
if ~strcmp(lower(mode.Aest),'tls');
    a  = EE(1:(q-1)*p,:)\EE(p+1:q*p,:);  % LS (Kung)
else
    a = tls(EE(1:(q-1)*p,:),EE(p+1:q*p,:)); % TLS 
end
a = conj(a); %%LL


if stab
    a = mirror2(a); % To do or not do?
end

clear V  EE;


fk = mimofr(a,eye(n),c,[],exp(i*w));
idx0 = (0:N-1)*p;
R = zeros(N*p,n*m+p*nestD);
% disp('Form linear relations');
estidx = 0;
for uix=1:m
    ud = spdiags(u(:,uix),0,N,N);
    for yix=1:p
        if n==1,
            R(idx0+yix,[1:n]+(uix-1)*n + p*nestD) = ud*squeeze(fk(yix,: ... 
                ,:));
        else
            R(idx0+yix,[1:n]+(uix-1)*n + p*nestD) = ud*squeeze(fk(yix,: ...
                ,:)).';
        end
        if nk(uix)==0, %Add input to regressor matrix
            R(idx0+yix,estidx*p+yix) = u(:,uix); 
        end
    end
    if nk(uix)==0,
        estidx = estidx+1;
    end
end
clear fk ud
H = y.';
H = H(:);

% disp('Solve LS problem for B and D');
if realflag
    Rr = [real(R); imag(R)];
    Hr = [real(H); imag(H)];
else
    Rr = R;
    Hr = H;
end
DB = Rr\Hr;
err = Hr-Rr*DB;
V0 = err'*err/length(H);

% disp(['cond(R) = ', num2str(cond(R))]);

b = zeros(n,m);
if estx0,
    d = zeros(p,m-nexp);
else
    d = zeros(p,m);
end

dcolidx = find(nk==0);
if nestD,
    d(:,dcolidx) = reshape(DB(1:p*nestD),p,nestD);
    b(:) = DB(p*nestD+1:end);
else
    % b(:) = DB(p*m+1:end);
    b(:) = DB;
end


if estx0,
    %  x0 = b(:,end-nexp+1:end);
    x0 = b(:,end);
    %  disp('d part of x0');
    %  d(:,end)
    b = b(:,1:end-nexp);
else
    x0 =zeros(n,1);
end
%% End fsid_estim %%%


function x = tls(a,b);
% Solves the overdetermined equation system 
%  ax ~ b 
% using the total least-squares method
n = size(a,2); 
[U,S,V] = svd([ a b ],0);
x = V(1:n,1:n)'\V(n+1:end,1:n)';
disp('tls');
%%% end tls %%%


function answ = check_inpidf(u,w,n);
% Check if the data supports simultaneous estimation of both B and X0.
[N,m] = size(u);
Wd = spdiags(exp(i*w),0,N,N);
U = zeros(N,n*m);
U(:,1:m) = u;
for x = 1:n-1,
    U(:, 1+x*m:(x+1)*m) = Wd * U(:, 1+(x-1)*m : x*m);
end
answ = (rank(U) == m*n);
%%%%%%%%%%%%%%%%%%%%

function X = mypinv(A,tol,setrank)
%MYPINV   Pseudoinverse.
%       X = MYPINV(A) produces a matrix X of the same dimensions
%       as A' so that A*X*A = A, X*A*X = X and AX and XA
%       are Hermitian. The computation is based on SVD(A) and any
%       singular values less than a tolerance S(1)*tol are treated as zero 
%       where S(1) is the largest singular value.
%       Default value of tol is max(nr,nc)*eps;
%
%       mypinv(A,tol) allows to set the tolerance explicitly
%       mypinv(A,[],setrank) calculates the psuedo-inverse explicitly 
%       truncating the rank of A to setrank


% Tomas McKelvey 951026, 960202



[nr,nc]=size(A);
if nargin<2, 
    tol = [];
end;
if nr<nc, A = A'; end;

[U,S,V] = svd(A,0);
if min(size(S)) == 1
    S = S(1);
else
    S = diag(S);
end
if nargin<3,
    if isempty(tol), 
        tol = max(nr,nc) * eps;
    end;
    r = sum(S > S(1)*tol);
else 
    r = setrank;
end
if (r == 0)
    X = zeros(size(A'));
else
    S = diag(ones(r,1)./S(1:r));
    X = V(:,1:r)*S*U(:,1:r)';
end
if nr<nc, X = X'; end;

function M = blockdiag(D);

% M = blockdiag(D);
%
% Creates a sparse blockdiagonal matrix with blocks given by D.
% Example
% D = [ 1 2 ; 3 4 ; 5 6; 7 8]
% M = blockdiag(D) 
% M = [ 1 2 0 0 
%       3 4 0 0
%       0 0 5 6
%       0 0 7 8];

% T. McKelvey 951120

[nb,bs] = size(D);
nb = nb/bs;
M = sparse([],[],[],nb*bs,nb*bs,nb*bs*bs);
for k = 1:nb,
    M( (k-1)*bs+1:k*bs,(k-1)*bs+1:k*bs) = D((k-1)*bs+1:k*bs,:);
end;


