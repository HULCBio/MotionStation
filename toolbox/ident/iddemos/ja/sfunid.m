% SFUNID は、システム同定を行う S-function です。
% この M-ファイルは、Simulink S-function ブロックの中で使用するように設計
% されています。これは、システムの入出力データをバッファに格納し、その後
% System Identification Toolbox を使って、線形モデルとして同定します。
%
% 入力引数は、つぎのものです。
%     order:          モデルの次数(通常は、ベクトルです)
%     npts:           fft の計算で使用する点数 (たとえば、128です)
%     HowOften:       fft の結果をプロットする頻度 (たとえば、64です)
%     offset:         サンプル時間オフセット(通常、ゼロです)
%     ts:             サンプル時間 (秒単位)
%     method:         同定に使用する手法：
% 	              'ar', 'arx', 'oe', 'armax', 'bj', 'pem'
%
% システム同定ブロックは、2つのプロット、実際のデータの時系列と予測データ
% の時系列、関連する誤差項を表示します。
%
% 参考： SIMIDENT, MASKIDENT, SFUNTMPL.

%   Copyright 1986-2001 The MathWorks, Inc.
