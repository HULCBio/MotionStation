% BODERESP は、モデルの周波数応答を、標準偏差と共に計算します。
% 
%   [MAG,PHASE,W] = BODERESP(M)   
%
% ここで、M はモデルオブジェクト(IDMODEL, IDPOLY, IDSS, IDFRD, IDGREY)で
% す。MAG は、応答のゲインで、PHASE は位相(度単位)です。W は、応答が計算
% される周波数を表すベクトルです。周波数ベクトルは、[MAG,PHASE,W] = BOD-
% ERESP(M,W) で指定できます。周波数単位は、rad/s です。
%
% M が、NY 出力と NU 入力をもち、W が、NW 個の周波数である場合、MAG と 
% PHASE は、NY-NU-NW の大きさの配列で、MAG(ky,ku,k) は、入力ku から出力 
% ky までの周波数 W(k) での応答を与えます。
%
% M が時系列の場合、MAG は、パワースペクトルを意味し、PHASE は、常にゼロ
% になります。
% 
% この関数は、離散時間モデルも連続時間モデルも機能します。
%   
% モデル M の出力に関連したノイズスペクトルを得るために、BODERESP(M('no-
% ise')) を使います。特定の入力/出力応答にアクセスするためには、BODERESP
% (M(ky,ku))を使います。
%
% ゲインと位相の標準偏差は、つぎのステートメントで表されます。
% 
%   [MAG,PHASE,W,SDMAG,SDPHAS] = BODERESP(M).
%   
% 参考： IDMODEL/BODE, FFPLOT, IDMODEL/NYQUIST, IDFRD

%   L. Ljung 7-7-87,1-25-92


%   Copyright 1986-2001 The MathWorks, Inc.
