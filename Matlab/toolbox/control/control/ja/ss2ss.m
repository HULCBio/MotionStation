% SS2SS   状態空間モデルの状態座標変換
%
%
% SYS = SS2SS(SYS,T) は、状態空間モデル SYS の状態ベクトル x に対して、
% 相似変換 z = Tx を行います。結果の状態空間モデルは、つぎのように表現
% されます。
%
%                .       -1        
%                z = [TAT  ] z + [TB] u
%                        -1
%                y = [CT   ] z + D u
%
% または、ディスクリプタの場合は、つぎのようになります。
%
%            -1  .       -1        
%        [TET  ] z = [TAT  ] z + [TB] u
%                        -1
%                y = [CT   ] z + D u 
%
% SS2SS は、連続時間と離散時間の両方のモデルに適応できます。
% LTI 配列SYS に対して、変換 T は配列内の個々のモデルに対して実行さ
% れます。
%
% 参考 : CANON, SSBAL, BALREAL.


% Copyright 1986-2002 The MathWorks, Inc.
