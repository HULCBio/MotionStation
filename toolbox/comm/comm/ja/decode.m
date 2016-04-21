% DECODE ブロック復号
%
% MSG = DECODE(CODE, N, K, METHOD...) は、誤り制御符号化手法を使って、
% CODE を復号します。METHOD と他のパラメータに関する情報と、特定の手法の
% 使用方法について情報を得るには、MATLAB プロンプトでつぎのいずれかの
% コマンドをタイプしてください。
% 
%         詳細はタイプしてください   符号化法
%         decode hamming             % ハミング
%         decode linear              % 線形ブロック
%         decode cyclic              % 巡回
%         decode bch                 % BCH
%
% 参考： ENCODE, BCHPOLY, CYCLPOLY, SYNDTABLE, GEN2PAR, BCHDECO.


%   Copyright 1996-2002 The MathWorks, Inc.
%   $Revision: 1.6.4.1 $  $Date: 2003/06/23 04:34:22 $
