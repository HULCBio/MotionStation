function [est, v, w, iter] = normest1(A, t, X, varargin)
%NORMEST1 Estimate of 1-norm of matrix by block 1-norm power method.
%   C = NORMEST1(A) returns an estimate C of norm(A,1), where A is N-by-N.
%   A can be an explicit matrix or a function AFUN such that
%   FEVAL(@AFUN,FLAG,X) for the following values of
%     FLAG       returns
%     'dim'      N
%     'real'     1 if A is real, 0 otherwise
%     'notransp' A*X
%     'transp'   A'*X
%
%   C = NORMEST1(A,T) changes the number of columns in the iteration matrix
%   from the default 2.  Choosing T <= N/4 is recommended, otherwise it should
%   be cheaper to form the norm exactly from the elements of A, as is done
%   when N <= 4 or T == N.  If T < 0 then ABS(T) columns are used and trace
%   information is printed.  If T is given as the empty matrix ([]) then the
%   default T is used.
%
%   C = NORMEST1(A,T,X0) specifies a starting matrix X0 with columns of unit
%   1-norm and by default is random for T > 1.  If X0 is given as the empty
%   matrix ([]) then the default X0 is used.
%
%   C = NORMEST1(AFUN,T,X0,P1,P2,...) passes extra inputs P1,P2,... to
%   FEVAL(@AFUN,FLAG,X,P1,P2,...).
%
%   [C,V] = NORMEST1(A,...) and [C,V,W] = NORMEST1(A,...) also return vectors
%   V and W such that W = A*V and NORM(W,1) = C*NORM(V,1).
%
%   [C,V,W,IT] = NORMEST1(A,...) also returns a vector IT such that
%   IT(1) is the number of iterations,
%   IT(2) is the number of products of N-by-N by N-by-T matrices.
%   On average, IT(2) = 4.
%
%   Note: NORMEST1 calls RAND.  If repeatable results are required then
%   invoke RAND('STATE',J), for some J, before calling this function.
%
%   See also CONDEST.

%   Subfunctions: MYSIGN, UNDUPLI, NORMAPP.

%   Reference: N. J. Higham and F. Tisseur,
%   A block algorithm for matrix 1-norm estimation, with an application
%   to 1-norm pseudospectra.
%   SIAM J. Matrix Anal. Appl., 21(4):1185-1201, 2000.

%   Nicholas J. Higham, 9-8-99
%   Copyright 1984-2004 The MathWorks, Inc.
%   $Revision: 1.8.4.2 $  $Date: 2004/01/24 09:22:14 $

% Determine whether A is a matrix or a function.
if isa(A,'double')
   n = max(size(A));
   A_is_real = isreal(A);
elseif isa(A,'function_handle')
   n = normapp(A,'dim',[],varargin{:});
   A_is_real = normapp(A,'real',[],varargin{:});
else
   error('MATLAB:normest1:ANotMatrixOrFunction','A must be a matrix or function.');
end

if nargin < 2 || isempty(t), t = 2; end
prnt = (t < 0);
t = abs(t);
if t ~= round(t) || t < 1 || t > max(n,2)
   error('MATLAB:normest1:TOutOfRange',...
         'T must be an integer between 1 and N = MAX(SIZE(A)).')
end
rpt_S = 0; rpt_e = 0;

if t == n || n <= 4
   if isa(A,'double')
      Y = A;
   else
      X = eye(n);
      Y = normapp(A,'notransp',X,varargin{:});
   end
   [temp,m] = sort( sum(abs(Y)) );
   est = temp(n); v = zeros(n,1); v(m(n)) = 1; w = Y(:,m(n));
   iter = [0 1]; red = [0 0]; info = 6;
   if prnt, fprintf('No iteration - norm computed exactly.\n'), end
   return
end

if nargin < 3 || isempty(X)
   X = ones(n,t);
   X(:,2:t) = mysign(2*rand(n,t-1) - ones(n,t-1));
   X = undupli(X, [], prnt);
   X = X/n;
end

if size(X,2) ~= t 
  error('MATLAB:normest1:WrongColNum',...
        ['X0 should have ' int2str(t) ' columns.']);
end

itmax = 5;  % Maximum number of iterations.
it = 0; nmv = 0;

ind = zeros(t,1); vals = zeros(t,1); Zvals = zeros(n,1); S = zeros(n,t);
est_old = 0;

while 1
    it = it + 1;

    if isa(A,'double')
       Y = A*X;
    else
       Y = normapp(A,'notransp',X,varargin{:});
    end
    nmv = nmv + 1;

    vals = sum(abs(Y));
    [temp, m] = sort(vals); m = m(t:-1:1);
    vals = vals(m); vals_ind = ind(m);
    est = vals(1);

    if est > est_old || it == 2, est_j = vals_ind(1); w = Y(:,m(1)); end

    if prnt
       fprintf('%g: ', it)
       for i = 1:t, fprintf(' (%g, %6.2e)', vals_ind(i), vals(i)), end
       fprintf('\n')
    end

    if it >= 2 && est <= est_old
       est = est_old;
       info = 2; break
    end
    est_old = est;

    if it > itmax, it = itmax; info = 1; break, end

    S_old = S;
    S = mysign(Y);
    if A_is_real
        SS = S_old'*S; np = sum(max(abs(SS)) == n);
        if np == t, info = 3; break, end
        % Now check/fix cols of S parallel to cols of S or S_old.
        [S, r] = undupli(S, S_old, prnt); rpt_S = rpt_S + r;
    end

    if isa(A,'double')
       Z = A'*S;
    else
       Z = normapp(A,'transp',S,varargin{:});
    end
    nmv = nmv + 1;

    % Faster version of `for i=1:n, Zvals(i) = norm(Z(i,:), inf); end':
    Zvals = max(abs(Z),[],2);

    if it >= 2
       if max(Zvals) == Zvals(est_j), info = 4; break, end
    end

    [temp, m] = sort(Zvals); m = m(n:-1:1);
    imax = t; % Number of new unit vectors; may be reduced below (if it > 1).
    if it == 1 
       ind = m(1:t);
       ind_hist = ind;
    else
       rep = sum(ismember(m(1:t), ind_hist));
       rpt_e = rpt_e + rep;
       if rep && prnt, fprintf('     rep e_j = %g\n',rep), end
       if rep == t, info = 5; break, end
       j = 1;
       for i = 1:t
           if j > n, imax = i-1; break, end
           while any( ind_hist == m(j) )
              j = j+1;
              if j > n, imax = i-1; break, end
           end
           if j > n, break, end
           ind(i) = m(j);
           j = j+1;
       end
       ind_hist = [ind_hist; ind(1:imax)];
    end

    X = zeros(n,t);
    for j=1:imax, X(ind(j),j) = 1; end
end

if prnt
   switch info
        case 1, fprintf('*Terminate: iteration limit reached.\n')
        case 2, fprintf('*Terminate: estimate not increased.\n')
        case 3, fprintf('*Terminate: repeated sign matrix.\n')
        case 4, fprintf('*Terminate: power method convergence test.\n')
        case 5, fprintf('*Terminate: repeated unit vectors.\n')
   end
end

iter = [it; nmv]; red = [rpt_S; rpt_e];

v = zeros(n,1); v(est_j) = 1;
if ~prnt, return, end

if A_is_real, fprintf('Parallel cols: %g\n', red(1)), end
fprintf('Repeated unit vectors: %g\n', red(2))

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Subfunctions.

function [S, r] = undupli(S, S_old, prnt)
%UNDUPLI   Look for and replace columns of S parallel to other columns of S or
%          to columns of Sold.

[n, t] = size(S);
r = 0;
if t == 1, return, end

if isempty(S_old) % Looking just at S.
   W = [S(:,1) zeros(n,t-1)];
   jstart = 2;
   last_col = 1;
else              % Looking at S and S_old.
   W = [S_old zeros(n,t-1)];
   jstart = 1;
   last_col = t;
end

for j=jstart:t
    rpt = 0;
    while max(max(abs( S(:,j)'*W(:,1:last_col) ))) == n
          rpt = rpt + 1;
          S(:,j) = mysign(2*rand(n,1) - ones(n,1));
          if rpt > n/t, break, end
    end
    if prnt && rpt > 0, fprintf('Unduplicate, rpt = %g\n', rpt), end
    r = r + sign(rpt);
    if j < t
       last_col = last_col + 1;
       W(:,last_col) = S(:,j);
    end
end


function S = mysign(A)
%MYSIGN      True sign function with MYSIGN(0) = 1.
S = sign(A);
S(find(S==0)) = 1;


function y = normapp(afun,flag,x,varargin)
%NORMAPP   Call matrix operator and error gracefully.
%   NORMAPP(AFUN,FLAG,X) calls matrix operator AFUN with flag
%   FLAG and matrix X.
%   NORMAPP(AFUN,FLAG,X,...) allows extra arguments to
%   AFUN(FLAG,X,...).
%   NORMAPP is designed for use by NORMEST1.

try
   y = feval(afun,flag,x,varargin{:});
catch
   es = sprintf(['function %s\n' ...
         'failed with the following error:\n\n%s'], func2str(afun), lasterr);
   error('MATLAB:normest1:Failure', es);
end

if isequal(flag,'notransp') || isequal(flag,'transp')
   if ~isequal(size(y),size(x))
      es = sprintf(['function %s\n' ...
            'must return a %d-by-%d matrix ' ...
            'when flag == ''%s'''], func2str(afun), ...
            size(x,1), size(x,2), flag);
      error('MATLAB:normest1:MatrixSizeMismatchFlag', es)
   end
end

if isequal(flag,'dim')
   if y ~= round(y) | y < 0
      es = sprintf(['function %s\n' ...
            'must return a nonnegative integer ' ...
            'when flag == ''%s'''], func2str(afun), flag);
      error('MATLAB:normest1:NegInt', es)
   end
end

if isequal(flag,'real')
   if y ~= 0 & y ~= 1
      es = sprintf(['function %s\n' ...
            'must return 0 or 1 ' ...
            'when flag == ''%s'''], func2str(afun), flag);
      error('MATLAB:normest1:Not0or1', es)
   end
end
