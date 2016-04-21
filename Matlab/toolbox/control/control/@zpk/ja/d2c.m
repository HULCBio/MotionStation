% D2C   離散時間LTIモデルを連続時間に変換
%
% SYSC = D2C(SYSD,METHOD) は、離散時間LTIモデル SYSD と等価な連続時間
% モデル SYSC を作成します。
% 
% 文字列 METHOD は、つぎの中から離散化手法を選択します。
%
%   'zoh'       入力に0次ホールドを適用
%   'tustin'    双1次(Tustin)近似
%   'prewarp'   変換前と変換後で、設定した(臨界)周波数で、応答が一致する
%               制約のもとで、Tustin 近似を行います。臨界周波数Wc(rad/s)
%               は、SYSD = C2D(SYSC,TS,'prewarp',Wc) で設定するように、
%               4番目の入力引数として設定します。
%   'matched'   Matched pole-zero 法(SISOシステムのみ)
% 
% METHOD が省略されると、デフォルトの手法 'zoh' が用いられます。
%
% 参考 : C2D, D2D, LTIMODELS.


%   Clay M. Thompson  7-19-90
%   Revised: P. Gahinet  8-27-96
%   Copyright 1986-2002 The MathWorks, Inc. 
