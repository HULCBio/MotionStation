%  [rate,P] = decay(pds,options)
%
% ポリトピックシステム、または、パラメータ依存システムの2次減衰率を計算
%
% DECAYは、パラメータベクトルpの値の範囲で、つぎのようなLyapunov行列 Q >
% 0について、tを最小化します。
%
%        A(p)*Q*E(p)' + E(p)*Q*A(p)'  <   t * E(p)*Q*E(p)'
%
% システムは、tmin < 0ならば2次的に安定です。
%
% 入力:
%   PDS       ポリトピックシステム、または、パラメータ依存システム(PSYS
%             を参照)。
%   OPTIONS   オプションの2要素ベクトル。
%             OPTIONS(1)=0 :  高速モード(デフォルト)
%                       =1 :  最も保守性のないモード
%             OPTIONS(2)   :  Pの条件数の限界値(デフォルト = 1e9)。
%  出力:
%   RATE      減衰率
%   P         Lyapunov行列P = inv(Q)
%
% 参考：    QUADSTAB, MUSTAB, PDLSTAB.



%  Copyright 1995-2002 The MathWorks, Inc. 
