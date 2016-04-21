function d = mahal(Y,X);
% MAHAL Mahalanobis distance.
%   MAHAL(Y,X) gives the Mahalanobis distance of each point in
%   Y from the sample in X. 
%   
%   The number of columns of Y must equal the number
%   of columns in X, but the number of rows may differ.
%   The number of rows must exceed the number of columns
%   in X.

%   Copyright 1993-2004 The MathWorks, Inc. 
%   $Revision: 2.11.4.1 $  $Date: 2003/11/01 04:26:57 $

[rx,cx] = size(X);
[ry,cy] = size(Y);

if cx ~= cy
   error('stats:mahal:InputSizeMismatch',...
         'Requires the inputs to have the same number of columns.');
end

if rx < cx
   error('stats:mahal:TooFewRows',...
         'The number of rows of X must exceed the number of columns.');
end
if any(imag(X(:))) | any(imag(Y(:)))
   error('stats:mahal:NoComplex','MAHAL does not accept complex inputs.');
end

m = mean(X,1);
M = m(ones(ry,1),:);
C = X - m(ones(rx,1),:);
[Q,R] = qr(C,0);

ri = R'\(Y-M)';
d = sum(ri.*ri,1)'*(rx-1);

