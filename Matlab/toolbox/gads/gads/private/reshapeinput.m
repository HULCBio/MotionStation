function [X] = reshapeinput(Xin, X)
% RESHAPEINPUT reshape X to match the shape of Xin 

%   Copyright 2004 The MathWorks, Inc
%   $Revision: 1.4 $  $Date: 2004/01/16 16:50:46 $


[m,n] = size(Xin);

%When X is passed in , it is assumed to be a column major matrix (or
%vector).
if m == n    && m == 1  % scalar input
    return;             % Retain column major.
elseif m > n && n == 1  % col major input 
    return;
elseif n > m && m == 1 % row major input
    X = X';
else                    % Matrix input; only for non-vectorized case.
    p = size(X,2);
    if p > 1          % Matrix Xin with vectorized 'on' 
        X = reshape(X,m,n,p);
    else
        X = reshape(X,m,n);
    end
end

