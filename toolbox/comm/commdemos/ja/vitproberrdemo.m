% VITPROBERRDEMO    VITSIMDEMO のエラーの理論確率を計算
%
% VITPROBERRDEMO(BER, DIST, NUMERR) cは、硬判定復号を使った畳込み符号の
% エラーの確率を計算します。BER は生のチャネルビットエラーレートを含む
% ベクトルです。DIST は、トレリス内のエラーパスの距離を示すベクトルです。
% NUMERR は、トレリスの各パスで発生したエラーの数を含むベクトルです。
% 計算されたパフォーマンスは、復号器パフォーマンス内の上界(Union Bound)
% です。


%   Copyright 1996-2002 The MathWorks, Inc.
%   $Revision: 1.1.4.1 $ $Date: 2003/06/23 04:35:33 $

