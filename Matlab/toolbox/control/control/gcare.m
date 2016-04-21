function varargout = gcare(H,varargin)
%GCARE  Generalized solver for continuous algebraic Riccati equations.
%
%   [X,L,REPORT] = GCARE(H,J,NS) computes the unique stabilizing
%   solution X of the continuous-time algebraic Riccati equation
%   associated with a Hamiltonian pencil of the form
% 
%                  [  A     F     S1 ]       [  E   0   0 ]
%      H - t J  =  [  G    -A'   -S2 ]  - t  [  0   E'  0 ]
%                  [ S2'   S1'     R ]       [  0   0   0 ]
% 
%   The optional input NS is the row size of the A matrix.  Default 
%   values for J and NS correspond to E=I and R=[].
%
%   Optionally, GCARE returns the vector L of closed-loop eigenvalues and
%   a diagnosis REPORT with value:
%     * -1 if the Hamiltonian pencil has jw-axis eigenvalues
%     * -2 if there is no finite stabilizing solution X
%     * 0 if a finite stabilizing solution X exists
%   This syntax does not issue any error message when X fails to exist.
%
%   [X1,X2,D,L] = GCARE(H,...,'factor') returns two matrices X1, X2 
%   and a diagonal scaling matrix D such that X = D*(X2/X1)*D.
%   The vector L contains the closed-loop eigenvalues.  All outputs 
%   are empty when the associated Hamiltonian matrix has eigenvalues 
%   on the imaginary axis.
%
%   [...] = GCARE(H,...,'nobalance') disables automatic scaling of 
%   the data.
%
%   See also CARE, GDARE.

%   Author(s): Pascal Gahinet
%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $ $Date: 2004/04/10 23:13:35 $

% Flags
idx1 = find(strcmp(varargin,'factor'));
FactorFlag = (~isempty(idx1));
idx2 = find(strcmp(varargin,'nobalance'));
NoBalanceFlag = (~isempty(idx2));

% J and NS
varargin(:,[idx1,idx2]) = [];
nextra = length(varargin);
if nextra<1
   J = [];
else
   J = varargin{1};
end
if nextra<2
   n = size(H,1)/2;
   if n~=round(n)
      error('Size of H matrix must be even when size of A is not specified.')
   end
else
   n = varargin{2};
end

% Error checks
n2 = 2*n;
m = size(H,1)-n2;
if ~isempty(J) && ~isequal(size(H),size(J))
   error('Matrices H and J must be the same size.')
elseif isempty(J) && m>0
   % Must go to pencil because of compression step
   J = blkdiag(eye(n2),zeros(m));
end

% Scale Hamiltonian matrix/pencil (D = state matrix scaling)
% RE: Before compression to preserve Hamiltonian structure
if NoBalanceFlag
   D = ones(n,1);  perm = 1:n2;
else
   [H,J,D,perm] = arescale(H,J,n);
end

% Grab E matrix
if ~isempty(J)
   E = J(1:n,1:n);
end

% Compression step on H(:,n2+1:n2+m) = [S1;-S2;R]
if m>0
   [q,r] = qr(H(:,n2+1:n2+m));
   H = q(:,m+1:n2+m)'*H(:,1:n2);
   J = q(1:n2,m+1:n2+m)'*J(1:n2,1:n2);
end

% Solve equation
sw = warning('off'); lw = lastwarn;
if isempty(J)
   % Hamiltonian matrix
   % RE: Apply triangularizing permutation to enhance SCHUR numerics (g147863)
   if isreal(H)
      [z,t] = schur(H(perm,perm),'real');
   else
      [z,t] = schur(H(perm,perm),'complex');
   end
   
   % Reorder eigenvalues to push stable eigenvalues to the top
   [z(perm,:),t] = ordschur(z,t,'lhp');
   L = eig(t);
     
else
   % Hamiltonian pencil
   % Use QZ algorithm to deflate pencil
   if isreal(H) && isreal(J)
      [HH,JJ,q,z] = qz(H(perm,perm),J(perm,perm),'real');
   else
      [HH,JJ,q,z] = qz(H(perm,perm),J(perm,perm),'complex');
   end
   
   % Reorder eigenvalues to push stable eigenvalues to the top
   [HH,JJ,q,z(perm,:)] = ordqz(HH,JJ,q,z,'lhp');
   L = eig(HH,JJ);
   
   % Account for non-identity E matrix and orthonormalize basis
   if ~isequal(E,eye(n))
      ez1 = E*z(1:n,1:n);
      [q,r] = qr([ez1;z(n+1:n2,1:n)]);
      z = q(:,1:n);
   end

end
lastwarn(lw); warning(sw);
X1 = z(1:n,1:n);
X2 = z(n+1:n2,1:n);

% Check that stable invariant subspace was properly extracted
% RE: Lack of symmetry in X1'*X2 indicates that a stable invariant subspace of 
%     dimension n could not be reliably isolated
Report = arecheckout(X1,X2,(real(L)<0));
if Report<0
   X1 = [];  X2 = [];  D = [];  
end

% Build output argument list
L = L(1:n);
if FactorFlag
   varargout = {X1 X2 diag(D) L Report};
else
   % Compute X if requested
   [X,Report] = arefact2x(X1,X2,D,Report);
   varargout = {X L Report};
   
   % Exit errors
   if nargout<=2
      switch Report
         case -1
            error('Cannot order eigenvalues: spectrum too near the imaginary axis.')
         case -2
            error('Solution X is not finite.')
      end
   end  
end

