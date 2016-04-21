% CTRANSPOSE   状態空間モデルの共役転置
%
% TSYS = CTRANSPOSE(SYS) は、tsys = SYS' を実行します。
%
% データ(A,B,C,D)をもつ連続時間モデル SYS に対して、CTRANSPOSE は、データ
% (-A',-C',B',D')をもつ状態空間モデル TSYS を出力します。H(s) が、SYS の
% 伝達関数の場合、H(-s).'は、TSYSの伝達関数になります。
%
% データ(A,B,C,D)をもつ離散時間モデル SYS に対して、TSYS は、データ 
% (AA, AA*C', -B'*AA, D'-B'*AA*C')をもつ状態空間モデルになります。ここで、
% AA =inv(A') です。また、H(z) が SYS の伝達関数の場合、H(z^-1).' は、
% TSYS の伝達関数になります。
%
% 参考 : TRANSPOSE, SS, LTIMODELS.


%   Author(s): P. Gahinet
%   Copyright 1986-2002 The MathWorks, Inc. 
