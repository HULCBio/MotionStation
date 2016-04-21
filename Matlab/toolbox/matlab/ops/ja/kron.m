% KRON   Kroneckerのテンソル積
% 
% KRON(X,Y) は、X と Y のKroneckerのテンソル積です。
% 結果は、X の要素と Y の要素について取り得るすべての組み合わせの積から
% なる大きな行列になります。たとえば、X が2行3列の場合、KRON(X,Y) は
% つぎのようになります。
%
%    [ X(1,1)*Y  X(1,2)*Y  X(1,3)*Y
%      X(2,1)*Y  X(2,2)*Y  X(2,3)*Y ]
%
% X と Y のいずれかがスパースの場合、非ゼロ要素のみが乗算され、結果は
% スパースになります。


%   Previous versions by Paul Fackler, North Carolina State,
%   and Jordan Rosenthal, Georgia Tech.
%   Copyright 1984-2004 The MathWorks, Inc. 
