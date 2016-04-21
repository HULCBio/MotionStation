% CONJ   複素共役係数をもつモデルの作成
% 
% SYSC = CONJ(SYS) は、LTIモデル SYS のすべての係数の複素共役を適用する
% ことにより、複素共役モデル SYSC を構築します。たとえば、SYS が伝達関数
%       (2+i)/(s+i)
% である場合、CONJ(SYS) は、伝達関数 (2-i)/(s-i) を生成します。
% この操作は、部分分数表現の操作に対して有効です。
% 
% 参考 : TF, ZPK, SS, RESIDUE.


%   Author: P. Gahinet
%   Copyright 1986-2002 The MathWorks, Inc. 
