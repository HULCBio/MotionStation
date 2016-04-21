% CONVN   N次元のコンボリューション
% 
% C = CONVN(A、B)は、行列AとBのN次元のコンボリューションを行います。
% C = CONVN(A、B、'shape')は、解Cの大きさを制御します。
%   'full'   - (デフォルト)完全なN次元のコンボリューションを出力します。
%   'same'   - Aと同じサイズで結果の中心部分を出力します。
%   'valid'  - 配列にゼロを加えるという仮定なしに計算されたコンボリュー
%              ションの部分のみを計算します。
%              結果のサイズは、max(size(A)-size(B)+1,0)です。
%
% 参考：CONV, CONV2.

%   Steven L. Eddins, February 1996
%   Copyright 1984-2004 The MathWorks, Inc. 
