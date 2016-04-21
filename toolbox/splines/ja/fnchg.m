% FNCHG   型の構成要素の変更
%
% FNCHG(FN,PART,VALUE) は、FN の指定された PART を与えられた VALUE に
% 変更します。
% PART は、以下の(先頭のキャラクタ)のいずれかになります。
%      'dimension'     関数のターゲットの次元
%      'interval'      関数の基本区間
%
% 文字列 PART の最後に文字 z があると、PART に対して指定された VALUE の
% どのチェックも省略し、FN と一致させます。
%
% 例題: FNDIR は、N次元の値をもつ関数に適用されたときでも、ベクトル値の
% 関数を出力します。これは、以下のように修正することができます。
%
%      fdir = fnchg( fndir(f,direction), ...
%                    'dim',[fnbrk(f,'dim'),size(direction,2)] );
%
% 参考 : FNBRK


%   Copyright 1987-2003 C. de Boor and The MathWorks, Inc.
