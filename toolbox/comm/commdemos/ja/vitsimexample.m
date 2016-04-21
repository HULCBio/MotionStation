% 畳込み符号器とViterbi復号器シミュレーションの例題
%
% RATIOINFO = VITSIMEXAMPLE(EBNO,M) は、畳込み符号器と、硬判定復号を用いた
% Viterbi復号器を使って、加法的白色ガウスノイズ（AWGN）の上で、バイナリ
% 位相シフトキーイング（BPSK）または4値PSK（QPSK）の全体のシミュレーション
% を行います。VITSIMEXAMPLE は、VITDEMO のデモンストレーションを拡張し、
% 新しい畳込みトレリス生成器 POLY2TRELLIS、符号化器 CONVENC、復号器 
% VITDEC の使い方をさらに説明します。また、DMODCE, DDEMODCE, SYMERR, 
% BITERR, RANDSRC, AWGN という別の関数の利用もデモンストレーションします。
%
% VITSIMEXAMPLE は、与えられた Eb/No の値 EBNO の各値について、ビット
% エラーレートの上限の組を計算します。VITSIMEXAMPLE は Eb/No の値を含む
% ベクトル EBNO のもとで繰り返し、200 個のエラーが生成されるまで各 EBNO 
% の値について通信回線のシミュレーションを行います。結果のビットエラー
% レートは、パフォーマンスの境界と共にプロットされます。
%
% 参考文献:
%   Proakis, J. G. "Digital Communications", New York, NY,
%   McGraw-Hill, 1983
%   Oldenwalder, J. P. "Optimal Decoding of Convolutional Codes",
%   Ph.D. Dissertation, University of California Los Angeles,
%   Los Angeles, CA, 1970


%   Copyright 1996-2002 The MathWorks, Inc.
%   $Revision: 1.1.4.1 $ $Date: 2003/06/23 04:35:35 $
