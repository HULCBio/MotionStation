% COMPAND   μ法則、または、A法則圧縮/伸張による情報源符号化
%
% OUT = COMPAND(IN, PARAM, V) は、PARAM にμ、V にピーク振幅幅を設定した
% μ法則圧縮器を計算します。
% 
% OUT = COMPAND(IN, PARAM, V, METHOD) は、METHOD に設定する計算方法に
% より、μ または A 法則圧縮器あるいは伸張器計算を実行します。PARAM には
% μ値 または A 値を、V には入力信号ピーク幅を設定します。METHOD には、
% つぎの計算方法の1つを設定します。
% 
% METHOD = 'mu/compressor'   μ法則圧縮器
% METHOD = 'mu/expander'     μ法則伸張器
% METHOD = 'A/compressor'    A法則圧縮器
% METHOD = 'A/expander'      A法則伸張器
% 
% 実際問題として使用する一般的な値は、μ = 255、および、A = 87.6です。
%
% 参考： QUANTIZ, DPCMENCO, DPCMDECO.


%   Copyright 1996-2002 The MathWorks, Inc.
%   $Revision: 1.6.4.1 $
