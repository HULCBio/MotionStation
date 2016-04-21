function [Q,R] = qrinsert(Q,R,j,x,orient)
%QRINSERT Insert a column or row into QR factorization.
%   [Q1,R1] = QRINSERT(Q,R,J,X) returns the QR factorization of the matrix A1,
%   where A1 is A=Q*R with an extra column, X, inserted before A(:,J). If A has
%   N columns and J = N+1, then X is inserted after the last column of A.
%
%   QRINSERT(Q,R,J,X,'col') is the same as QRINSERT(Q,R,J,X).
%
%   [Q1,R1] = QRINSERT(Q,R,J,X,'row') returns the QR factorization of the matrix
%   A1, where A1 is A=Q*R with an extra row, X, inserted before A(J,:).
%
%   Example:
%      A = magic(5);  [Q,R] = qr(A);
%      j = 3; x = 1:5;
%      [Q1,R1] = qrinsert(Q,R,j,x,'row');
%   returns a valid QR factorization, although possibly different from
%      A2 = [A(1:j-1,:); x; A(j:end,:)];
%      [Q2,R2] = qr(A2);
%
%   Class support for inputs Q,R,X:
%      float: double, single
%
%   See also QR, QRDELETE, PLANEROT.

%   Copyright 1984-2004 The MathWorks, Inc.
%   $Revision: 5.11.4.2 $  $Date: 2004/04/10 23:30:07 $

if nargin < 5
    if nargin < 4
        error('MATLAB:qrinsert:NotEnoughInputs', 'Too few inputs.')
    end
    orient = 'col';
end

[mx,nx] = size(x);
[mq,nq] = size(Q);
[m,n] = size(R);

if isequal(orient,'col') && (n==0)
   [Q,R] = qr(x);
   return;
end

if isequal(orient,'row') && (m==0)
   [Q,R] = qr(x);
   return;
end

% Error checking
if (mq ~= nq)
    error('MATLAB:qrinsert:QNotSquare', 'Q must be square.')
elseif (nq ~= m)
    error('MATLAB:qrinsert:InnerDimQRfactors',...
          'Inner matrix dimensions of QR factors must agree.')
elseif (j <= 0)
    error('MATLAB:qrinsert:NegInsertionIndex',...
          'Insertion index must be positive.')
end

switch orient
case 'col'
    
    if (j > n+1)
        error('MATLAB:qrinsert:InvalidInsertionIndex',...
              'Insertion index exceeds matrix dimensions.')
    elseif (mx ~= m) || (nx ~= 1)
        error('MATLAB:qrinsert:WrongSizeInsertedCol',...
              'Inserted column has incorrect dimensions.') 
    end
    
    % Make room and insert x before j-th column.
    R(:,j+1:n+1) = R(:,j:n);
    R(:,j) = Q'*x;
    n = n+1;
    
    % Now R has nonzeros below the diagonal in the j-th column,
    % and "extra" zeros on the diagonal in later columns.
    %    R = [x x x x x         [x x x x x
    %         0 x x x x    G     0 x x x x
    %         0 0 + x x   --->   0 0 * * *
    %         0 0 + 0 x          0 0 0 * *
    %         0 0 + 0 0]         0 0 0 0 *]
    % Use Givens rotations to zero the +'s, one at a time, from bottom to top.
    %
    % Q is treated to (the transpose of) the same rotations.
    %    Q = [x x x x x    G'   [x x * * *
    %         x x x x x   --->   x x * * *
    %         x x x x x          x x * * *
    %         x x x x x          x x * * *
    %         x x x x x]         x x * * *]

    for k = m-1:-1:j
        p = k:k+1;
        [G,R(p,j)] = planerot(R(p,j));
        if k < n
            R(p,k+1:n) = G*R(p,k+1:n);
        end
        Q(:,p) = Q(:,p)*G';
    end
    
case 'row'
    
    if (j > m+1)
        error('MATLAB:qrinsert:InvalidInsertionIndex',...
              'Insertion index exceeds matrix dimensions.')
    elseif (mx ~= 1) || (nx ~= n)
        error('MATLAB:qrinsert:WrongSizeInsertedRow',...
              'Inserted row has incorrect dimensions.') 
    end
        
    R = [x; R];
    Q = [1 zeros(1,m,class(R)); zeros(m,1) Q];
    
    % Now R is upper Hessenberg.
    %    R = [x x x x         [* * * *
    %         + x x x    G       * * *
    %           + x x   --->       * *
    %             + x                *
    %               +          0 0 0 0
    %         0 0 0 0          0 0 0 0
    %         0 0 0 0]         0 0 0 0]
    % Use Givens rotations to zero the +'s, one at a time, from top to bottom.
    %
    % Q is treated to (the transpose of) the same rotations and then a row
    % permutation, p, to shuffle row 1 down to row j.
    %    Q = [1 | 0 0 0 0 0         [# # # # # #         [* * * * * *
    %         --|----------          -----------          -----------
    %         0 | x x x x x    G'    * * * * * *    p     * * * * * *
    %         0 | x x x x x   --->   * * * * * *   --->   # # # # # #
    %         0 | x x x x x          * * * * * *          * * * * * *
    %         0 | x x x x x          * * * * * *          * * * * * *
    %         0 | x x x x x]         * * * * * *]         * * * * * *]
    
    for i = 1 : min(m,n)
        p = i : i+1;
        [G,R(p,i)] = planerot(R(p,i));
        R(p,i+1:n) = G * R(p,i+1:n);
        Q(:,p) = Q(:,p) * G';
    end
    
    % This permutes row 1 of Q*R to row j of Q(p,:)*R
    if (j ~= 1)
        p = [2:j, 1, j+1:m+1];
        Q = Q(p,:);
    end
    
otherwise
    error('MATLAB:qrinsert:InvalidInput5',...
          'Fifth input must be the string ''row'' or ''col''');
end
