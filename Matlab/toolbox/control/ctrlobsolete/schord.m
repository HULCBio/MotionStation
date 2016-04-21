function [Qo, To] = schord(Qi, Ti, index)
%SCHORD Ordered schur decomposition.
%   [Qo, To] = schord(Qi, Ti, index)  Given the square (possibly 
%   complex) upper-triangular matrix Ti and orthogonal matrix Qi
%   (as output, for example, from the function SCHUR),
%   SCHORD finds an orthogonal matrix Q so that the eigenvalues
%   appearing on the diagonal of Ti are ordered according to the
%   increasing values of the array index where the i-th element
%   of index corresponds to the eigenvalue appearing as the
%   element  Ti(i,i).
%
%   The input argument list may be [Qi, Ti, index] or [Ti, index].
%   The output list may be [Qo, To] or [To].
%
%   The orthogonal matrix Q is accumulated in Qo as  Qo = Qi*Q.
%       If Qi is not given it is set to the identity matrix.
%
%          *** WARNING: SCHORD will not reorder REAL Schur forms.

%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.9 $  $Date: 2002/04/10 06:32:26 $

%  written-
%       11 May 87  M. Wette, ECE Dep't., Univ. of California,
%                            Santa Barbara, CA  93106, (805) 961-3616
%                  e-mail:   mwette%gauss@hub.ucsb.edu
%                            laub%lanczos@hbu.ucsb.edu
%  revised-
%       09 Sep 87  M. Wette 
%                  (fixed exit on first eigenvalue in correct place)
%       16 Mar 88  Wette & Laub
%                  (documentation)

[nr,nc] = size(Ti); n = nr;
if (nr ~= nc), error('Nonsquare Ti'); end;
if (nargin == 2)
    index = Ti; To = Qi;
else
    To = Ti;
end;
if (nargout > 1), if (nargin > 2), Qo = Qi; else Qo = eye(n); end; end;
%
for i = 1:(n-1),

    % -- find following element with smaller value of index --
    move = 0; k = i;
    for j = (i+1):n,
    if (index(j) < index(k)), k = j; move = 1; end;
    end;

    % -- propagate eigenvalue up the diagonal from k-th to i-th entry --
    if (move),
        for l = k:-1:(i+1)
        l1 = l-1; l2 = l;
        t = givens(To(l1,l1)-To(l2,l2), To(l1,l2));
        t = [t(2,:);t(1,:)];
        To(:,l1:l2) = To(:,l1:l2)*t; To(l1:l2,:) = t'*To(l1:l2,:);
        if (nargout > 1), Qo(:,l1:l2) = Qo(:,l1:l2)*t; end;
        ix = index(l1); index(l1) = index(l2); index(l2) = ix;
        end;
    end;
end;
% --- last line of schord.m ---
