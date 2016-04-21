% BETAINC   不完全beta関数
% 
% Y = BETAINC(X,Z,W) は、X、Z、W の対応する要素に対して、不完全beta関数を
% 計算します。X の要素は、閉区間 [0,1] 内になければなりません。引数 X、Z、
% W は、すべて同じサイズでなければなりません(または、いずれかがスカラでも
% 構いません)。
%
% 不完全beta関数は、つぎのように定義されます。
%
%   I_x(z,w) = 1./BETA(z,w) .* t.^(z-1) .* (1-t).^(w-1)   
%                                       dtの0からxまでの積分
%
% 不完全beta関数の上裾を計算するには、以下を使います。
%
%     1 - BETAINC(X,Z,W) = BETAINC(1-X,W,Z).
%
%
% 参考：BETA, BETALN.


%   Copyright 1984-2002 The MathWorks, Inc. 
