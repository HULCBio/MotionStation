% HKSV は、Hankel 特異値とグラミアン P, Q を計算します。
%
% [HSV,P,Q] = HKSV(A,B,C) は、可到達グラミアンと可観測グラミアン P,Q と 
% Hankel 特異値"hsv" を計算します。
%
% 不安定システムに対して、(-a,-b,c) が、代わりに使われ、つぎのようになりま
% す。
% 
%    "hsv = [hsv_stable;hsv_unstable]".

% Copyright 1988-2002 The MathWorks, Inc. 
