function [B,T] = rotatefactors(A, varargin)
%ROTATEFACTORS Rotation of FA or PCA loadings.
%   B = ROTATEFACTORS(A) rotates the D-by-M loadings matrix A to maximize
%   the varimax criterion, and returns the result in B.  Rows of A and B
%   correspond to variables and columns correspond to factors, e.g., the
%   (i,j)th element of A is the coefficient for the i-th variable on the
%   j-th factor.  The matrix A usually contains principal component
%   coefficients created with PRINCOMP or PCACOV, or factor loadings
%   estimated with FACTORAN.
%
%   B = ROTATEFACTORS(A, 'Method','orthomax', 'Coeff',GAMMA) rotates A to
%   maximize the orthomax criterion with the coefficient GAMMA, i.e., B is
%   the orthogonal rotation of A that maximizes
%
%      sum(D*sum(B.^4,1) - GAMMA*sum(B.^2,1).^2)
%
%   The default value of 1 for GAMMA corresponds to varimax rotation. Other
%   possibilities include GAMMA = 0, M/2, and D*(M-1)/(D+M-2), corresponding
%   to quartimax, equamax, and parsimax.  You may also supply the strings
%   'varimax', 'quartimax', 'equamax', or 'parsimax' for the 'method'
%   parameter and omit the 'Coeff' parameter.
%
%   If 'Method' is 'orthomax', 'varimax', 'quartimax', 'equamax', or
%   'parsimax', then additional parameters are:
%
%      'Normalize'  - Flag indicating whether the loadings matrix should
%                     be row-normalized for rotation.  If 'on' (the
%                     default), rows of A are normalized prior to rotation
%                     to have unit Euclidean norm, and unnormalized after
%                     rotation.  If 'off', the raw loadings are rotated and
%                     returned.
%      'Reltol'     - Relative convergence tolerance in the iterative
%                     algorithm used to find T.  Default is sqrt(eps).
%      'Maxit'      - Iteration limit in the iterative algorithm used to
%                     find T.  Default is 250.
%
%   B = ROTATEFACTORS(A, 'Method','procrustes', 'Target',TARGET) performs
%   an oblique procrustes rotation of A to the D-by-M target loadings
%   matrix TARGET.
%
%   B = ROTATEFACTORS(A, 'Method','pattern', 'Target',TARGET) performs an
%   oblique rotation of the loadings matrix A to the D-by-M target pattern
%   matrix TARGET, and returns the result in B.  TARGET defines the
%   "restricted" elements of B, i.e., elements of B corresponding to zero
%   elements of TARGET are constrained to have small magnitude, while
%   elements of B corresponding to nonzero elements of TARGET are allowed
%   to take on any magnitude.
%
%   If 'Method' is 'procrustes' or 'pattern', then an additional parameter
%   is:
%
%      'Type'  - Type of rotation. If 'orthogonal', the rotation is
%                orthogonal, and the factors remain uncorrelated.  If
%                'oblique' (the default), the rotation is oblique, and the
%                rotated factors may be correlated.
%
%   When 'Method' is 'pattern', there are restrictions on TARGET.  If A has
%   M columns, then for orthogonal rotation, the Jth column of TARGET must
%   contain at least M-J zeros.  For oblique rotation, each column of
%   TARGET must contain at least M-1 zeros.
%
%   B = ROTATEFACTORS(A, 'Method','promax') rotates A to maximize the
%   promax criterion, equivalent to an oblique Procrustes rotation with
%   a target created by an orthomax rotation.  Use the four orthomax
%   parameters to control the orthomax rotation used internally by promax.
%   An additional parameter for 'promax' is:
%
%      'Power'  - Exponent for creating promax target matrix.  Must be
%                 1 or greater, default is 4.
%
%   [B,T} = ROTATEFACTORS(A, ...) returns the rotation matrix T used to
%   create B, i.e., B = A*T.  inv(T'*T) is the correlation matrix of the
%   rotated factors.  For orthogonal rotation, this is the identity matrix,
%   while for oblique rotation, it has unit diagonal elements but nonzero
%   off-diagonal elements.
%
%   Examples:
%
%      X = randn(100,10);
%      L = princomp(X);
%
%      % Default (normalized varimax) rotation of the first three components
%      % from a PCA.
%      [L1,T] = rotatefactors(L(:,1:3));
%
%      % Equamax rotation of the first three components from a PCA.
%      [L2,T] = rotatefactors(L(:,1:3),'method','equamax');
%
%      % Promax rotation of the first three components from a PCA.
%      L = factoran(X,3,'Rotate','none');
%      [L3,T] = rotatefactors(L,'method','promax','power',2);
%
%      % Pattern rotation of the first three components from a PCA.
%      Tgt = [1 1 1 1 1 0 1 0 1; 0 0 0 1 1 1 0 0 0; 1 0 0 1 0 1 1 1 1]';
%      [L4,T] = rotatefactors(L,'method','pattern','target',Tgt);
%      inv(T'*T) % the correlation matrix of the rotated factors
%
%   See also BIPLOT, FACTORAN, PRINCOMP, PCACOV, PROCRUSTES.

%   Copyright 1993-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $ $Date: 2004/01/24 09:36:50 $

%   References:
%     [1] Harman, H.H. (1976) Modern Factor Analysis, 3rd Ed., University
%         of Chicago Press.
%     [2] Lawley, D.N. and Maxwell, A.E. (1971) Factor Analysis as a
%         Statistical Method, 2nd Ed., American Elsevier Pub. Co.


% Default param values are defined in the individual rotation functions.
% The names 'coeffom', 'powerpm', 'targetprocr', 'typeprocr', are grandfathered
% in from factoran, but advertised as 'coeff', 'power', 'target', and 'type'.
names = {'method' 'normalize' 'coeffom' 'reltol' 'maxit' 'powerpm' ...
         'targetprocr' 'typeprocr'};
dflts = {'varimax' [] [] [] [] [] [] []};
[eid,errmsg,method,normalize,coeff,reltol,maxit,power,target,type] ...
                                = statgetargs(names, dflts, varargin{:});
if ~isempty(eid)
   error(['stats:rotatefactors:' eid],errmsg);
end

[d, m] = size(A);

if ischar(method)
    % This list also appears in factoran.  It should be updated there if it
    % changes here.
    methodNames = {'orthomax' 'varimax' 'quartimax' 'equamax' 'equimax' ...
                   'parsimax' 'procrustes' 'pattern' 'promax'};
    i = strmatch(lower(method), methodNames);
    if length(i) > 1
        % 'equimax' or 'equamax' are the same thing, accept 'equ'
        if all(ismember(i,[4 5]))
            method = methodNames{4}; % 'equamax'
        else
            error('stats:rotatefactors:BadRotation', ...
                  'Ambiguous ''method'' parameter value:  %s.', method);
        end
    elseif isempty(i)
        error('stats:rotatefactors:BadRotation', ...
              'Unknown ''method'' parameter value:  %s.', method);
    end
    method = methodNames{i};
else
    error('stats:rotatefactors:BadRotation', ...
          'The ''method'' parameter value must be a string.');
end

switch method
case 'orthomax'
    [B, T] = orthomax(A, coeff, normalize, reltol, maxit);
case 'varimax'
    [B, T] = orthomax(A, 1, normalize, reltol, maxit);
case 'quartimax'
    [B, T] = orthomax(A, 0, normalize, reltol, maxit);
case {'equamax' 'equimax'}
    [B, T] = orthomax(A, m/2, normalize, reltol, maxit);
case 'parsimax'
    [B, T] = orthomax(A, d*(m-1)/(d+m-2), normalize, reltol, maxit);
case 'procrustes'
    [B, T] = procrustes(A, target, type);
case 'pattern'
    [B, T] = pattern(A, target, type);
case 'promax'
    [B, T] = promax(A, power, coeff, normalize, reltol, maxit);
end


%------------------------------------------------------------------

function [B, T] = orthomax(A, gamma, normalize, reltol, maxit)
%ORTHOMAX Orthogonal rotation of FA or PCA loadings.
[d, m] = size(A);

% Defaults to normalized varimax rotation
if nargin < 2 | isempty(gamma)
    gamma = 1;
elseif gamma < 0
    error('stats:rotatefactors:BadCoefficient',...
          'The ''coeff'' parameter value must be nonnegative.');
end
if nargin < 3 | isempty(normalize), normalize = 'on'; end
if nargin < 4 | isempty(reltol), reltol = sqrt(eps(class(A))); end
if nargin < 5 | isempty(maxit), maxit = 250; end

% Normalize the factor loadings
switch normalize
case {'on',1}
    h = sqrt(sum(A.^2, 2));
    A = A ./ repmat(h, 1, size(A,2));
case {'off',0}
%     A = A;
otherwise
    error('stats:rotatefactors:BadNormalize',...
          'The ''Normalize'' parameter value must be ''on'' or ''off''.');
end
B = A;
T = eye(m);

converged = false;
if (0 <= gamma) && (gamma <= 1)
    % Use Lawley and Maxwell's fast version
    D = 0;
    for k = 1:maxit
        Dold = D;
        [L, D, M] = svd(A' * (d*B.^3 - gamma*B * diag(sum(B.^2))));
        T = L * M';
        D = sum(diag(D));
        B = A * T;
%         crit = sum(d*sum(B.^4,1) - gamma*sum(B.^2,1).^2)
        if (abs(D - Dold)/D < reltol)
            converged = true;
            break;
        end
    end
else
    % Use a sequence of bivariate rotations
    for iter = 1:maxit
        maxTheta = 0;
        for i = 1:(m-1)
            for j = (i+1):m
                Bi = B(:,i);
                Bj = B(:,j);
                u = Bi.*Bi - Bj.*Bj;
                v = 2*Bi.*Bj;
                usum = sum(u,1);
                vsum = sum(v,1);
                numer = 2*u'*v - 2*gamma*usum*vsum/d;
                denom = u'*u - v'*v - gamma*(usum^2 - vsum^2)/d;
                theta = atan2(numer, denom) / 4;
                maxTheta = max(maxTheta, abs(theta));
                Tij = [cos(theta) -sin(theta); sin(theta) cos(theta)];
                B(:,[i,j]) = B(:,[i,j]) * Tij;
                T(:,[i,j]) = T(:,[i,j]) * Tij;
            end
%         crit = sum(d*sum(B.^4,1) - gamma*sum(B.^2,1).^2)
        end
        if (maxTheta < reltol)
            converged = true;
            break;
        end
    end
end

if ~converged
    error('stats:rotatefactors:IterationLimit',...
          'Iteration limit exceeded for factor rotation.');
end

% Unnormalize the rotated loadings
switch normalize
case {'on',1}
    B = B .* repmat(h, 1, size(A,2));
% case {'off',0}
%    B = B;
end


%------------------------------------------------------------------

function [B, T] = procrustes(A, target, type)
%PROCRUSTES Procrustes rotation of FA or PCA loadings.
[d, m] = size(A);

if nargin < 2 | isempty(target)
    error('stats:rotatefactors:TargetRequired',...
          'A target matrix must be specified for procrustes rotation.');
elseif any(size(target) ~= [d m])
    error('stats:rotatefactors:InputSizeMismatch',...
          'The target matrix must be the same size as the loadings matrix.');
end
if nargin < 3 | isempty(type)
    type = 'oblique';
else
    typeNames = {'oblique','orthogonal'};
    i = strmatch(lower(type), typeNames);
    if length(i) > 1
        error('stats:rotatefactors:BadType',...
              'Ambiguous ''Type'' parameter value:  %s.', type);
    elseif isempty(i)
        error('stats:rotatefactors:BadType',...
              'Unknown ''Type'' parameter value:  %s.', type);
    end
    type = typeNames{i};
end

% Orthogonal rotation to target
switch type
case 'orthogonal'
    [L, D, M] = svd(target' * A);
    T = M * L';

% Oblique rotation to target
case 'oblique'
    % LS, then normalize
    T = A \ target;
    T = T * diag(sqrt(diag((T'*T)\eye(m)))); % normalize inv(T)
end
B = A * T;


%------------------------------------------------------------------

function [B, T] = pattern(A, target, type)
%PATTERN Rotation of FA or PCA loadings to a target pattern.
%   In the context of Factor Analysis, Lawley and Maxwell describe a
%   variation of this rotation where the rotation matrix is computed using
%   a loadings matrix whose rows have been weighted by the inverse sqrt of
%   the specific variances.  This can be done as
%
%      W = diag(1./sqrt(Psi));
%      [L,T] = PATTERN(W*L0); L = diag(sqrt(Psi))*L.
%
%   or equivalently,
%
%      [L,T] = PATTERN(W*L0); L = L0*T.
[d, m] = size(A);

if nargin < 2 | isempty(target)
    error('stats:rotatefactors:TargetRequired',...
          'A target matrix must be specified for pattern rotation.');
elseif ~isequal(size(target), [d m])
    error('stats:rotatefactors:InputSizeMismatch',...
          'The target matrix must be the same size as the loadings matrix.');
end
if nargin < 3 | isempty(type)
    type = 'oblique';
else
    typeNames = {'oblique','orthogonal'};
    i = strmatch(lower(type), typeNames);
    if length(i) > 1
        error('stats:rotatefactors:BadType',...
              'Ambiguous ''Type'' parameter value:  %s.', type);
    elseif isempty(i)
        error('stats:rotatefactors:BadType',...
              'Unknown ''Type'' parameter value:  %s.', type);
    end
    type = typeNames{i};
end

switch type
case 'orthogonal'
    if any(sum(target==0,1) < m-(1:m))
        error('stats:rotatefactors:BadTarget',...
              'The jth column of the target matrix must contain at least %d-j zeros.',m);
    end
    
    T = eye(m);
    for j = 1:(m-1)
        [Q,R] = qr(A,0);
        A0 = A; A0(target(:,j)==0,:) = 0;
        [dum,s,v] = svd(A0/R,0);
        u = R \ v(:,1);
        Tj = [u./norm(u) null(u')];
        T(:,j:m) = T(:,j:m) * Tj;
        B(:,j:m) = A * Tj;
        A = B(:,(j+1):m);
    end
    
case 'oblique'
    if any(sum(target==0,1) < m-1)
        error('stats:rotatefactors:BadTarget',...
              'Each column of the target matrix must contain at least %d zeros.',m-1);
    end
    
    T = zeros(m,m);
    [Q,R] = qr(A,0);
    for j = 1:m
        A0 = A; A0(target(:,j)==0,:) = 0;
        [dum,s,v] = svd(A0/R,0);
        T(:,j) = R \ v(:,1); % 1st eigenvector of inv(A'*A)*(A0'*A0)
    end
    T = T * diag(sqrt(diag((T'*T)\eye(m)))); % normalize inv(T)
    B = A * T;
end

% Make the largest element in each column of B positive.
[dum,idx] = max(abs(B),[],1); signer = diag(sign(B((0:(m-1))*d + idx)));
B = B * signer;
T = T * signer;


%------------------------------------------------------------------

function [B, T] = promax(A, power, gamma, normalize, reltol, maxit)
%PROMAX Promax oblique rotation of FA or PCA loadings.
[d, m] = size(A);

if nargin < 2 | isempty(power)
    power = 4;
elseif power < 1
    error('stats:rotatefactors:BadPower',...
          'The ''power'' parameter value must be 1 or greater.');
end
if nargin < 3, gamma = []; end
if nargin < 4, normalize = []; end
if nargin < 5, reltol = []; end
if nargin < 6, maxit = []; end

% Create target matrix from orthomax (defaults to varimax) solution
[B0, T0] = orthomax(A, gamma, normalize, reltol, maxit);
target = sign(B0) .* abs(B0).^power; % keep it real, respect sign

% Oblique rotation to target
[B, T] = procrustes(A, target, 'oblique');
