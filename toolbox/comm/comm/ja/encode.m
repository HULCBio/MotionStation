% ENCODE ブロック符号化
%
% CODE = ENCODE(MSG, N, K, METHOD, OPT) は、誤り制御符号化手法を使って、
% MSG を符号化します。パラメータについての情報と、特性の手法についての
% 情報を得るには、MATLABプロンプトで、つぎのいずれかのコマンドを入力して
% ください。
%
%         詳細はタイプしてください   符号化法
%         encode hamming             % ハミング
%         encode linear              % 線形ブロック
%         encode cyclic              % 巡回
%         encode bch                 % BCH
%
% 参考： DECODE, BCHPOLY, CYCLPOLY, CYCLGEN, HAMMGEN, BCHENCO.


%   Copyright 1996-2002 The MathWorks, Inc.
%   $Revision: 1.6.4.1 $   $Date: 2003/06/23 04:34:26 $ 

