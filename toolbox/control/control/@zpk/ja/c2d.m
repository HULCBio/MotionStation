% C2D   連続系から離散系への変換
%
% SYSD = C2D(SYSC,TS,METHOD) は、連続時間のLTIモデル SYSC を、サンプル
% 時間 TS で、離散時間モデル SYSD に変換します。文字列 METHOD は、つぎの
% 中から離散化手法を選択します。
%
%   'zoh'       入力に0次ホールドを適用
%   'foh'       入力に線形補間(三角近似)を適用
%   'imp'       インパルス不変離散化
%   'tustin'    双1次(Tustin)近似
%   'prewarp'   変換前と変換後で、設定した(臨界)周波数で、応答が一致する
%               制約のもとで、Tustin 近似を行います。臨界周波数Wc(rad/s)
%               は、SYSD = C2D(SYSC,TS,'prewarp',Wc) で設定するように、
%               4番目の入力引数として設定します。
%   'matched'   Matched pole-zero 法(SISOシステムのみ)
% 
% METHOD が省略されると、デフォルトの手法 'zoh' が用いられます。
%
% 状態空間モデル SYS に対して、
% 
%   [SYSD,G] = C2D(SYSC,TS,METHOD)
% 
% は、連続系の初期条件を離散系の初期条件に変換する行列 G も出力します。 
% 特に、x0、u0 を SYSC に対する初期状態と初期入力とするとき、SYSD に対する
% 等価な初期条件は
% 
%   xd0 = G * [x0;u0],     ud0 = u0 
% 
% となります。
%
% 参考 : D2C, D2D, LTIMODELS/


%	Clay M. Thompson  7-19-90, A. Potvin 12-5-95
%       P. Gahinet  7-18-96
%	Copyright 1986-2002 The MathWorks, Inc. 
