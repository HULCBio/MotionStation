% FZMULT   基本ヌル空間の基底を用いた乗算
%
% W = FZMULT(A,V) は、行列 Z と行列 V が W = Z*V となるような乗算 W を
% 計算します。ここで、Z は、行列 A のヌル空間に対する基本的な基底です。
% A は、m < n で rank(A) = m と rank(A(1:m,1:m)) = m となる、m×n の
% スパース行列でなければなりません。V は、p = n-m となる p×q の行列で
% なければなりません。V がスパースの場合、W はスパースとなり、そうで
% なければ、フルになります。
%
% W = FZMULT(A,V,'transpose') は、W = Z'*V となるように、転置した基本
% 的な基底 V をかけて乗算を行います。V は q = n-m となる p×q でなければ
% なりません。FZMULT(A,V) は、FZMULT(A,V,[]) と等しくなります。
%
% [W,L,U,pcol,P]  = FZMULT(A,V) は、A1 = A(1:m,1:m) と、P*A1(:,pcol) = L*U
% となる、行列 A(1:m,1:m) のスパースなLU分解を返します。
%
% W = FZMULT(A,V,TRANSPOSE,L,U,pcol,P) は、A1 = A(1:m,1:m) と、
% P*A1(:,pcol) = L*U として計算された行列 A(1:m,1:m) のスパースなLU分解
% を使います。
%
% ヌル空間の基底行列 Z は、明示的には形成されません。間接的な表現として
% A(1:m,1:m) のスパースなLU分解に基づいたものが使われます。


%   Copyright 1990-2003 The MathWorks, Inc.
%   $Revision: 1.7 $  $Date: 2002/03/26 16:58:01 $
