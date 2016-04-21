% C2Dは、連続系から離散系への変換を行います。
%
%
% SYSD = C2D(SYSC,TS,METHOD) は、連続時間の LTI モデル SYSC を、サンプル時間
% TS で、離散時間モデル SYSD に変換します。文字列 METHOD は、つぎの中から離散
% 化手法を選択します。'zoh'       入力に0次ホールドを適用
%    'foh'       入力に線形補間(三角近似)を適用
%    'imp'       インパルス不変離散化
%    'tustin'    双1次(Tustin)近似
%    'prewarp'   変換前と変換後で、設定した(臨界)周波数で、応答が一致する制約の
%                もとで、Tustin 近似を行います。 臨界周波数Wc(rad/s) は、
%                   SYSD = C2D(SYSC,TS,'prewarp',Wc) 
%                で設定するように、4番目の入力引数として設定します。
%    'matched'   Matched pole-zero 法(SISO システムのみ) METHOD が省略されると、
% デフォルトの手法 'zoh' が用いられます。
%
% [SYSD,G] = C2D(SYSC,TS,METHOD) は、連続系の初期条件を離散系の初期条件に変
% 換する行列 G も出力します。特に、x0、u0 を SYSC に対する初期状態と初期入力と
% するとき、SYSD に対する等価な初期条件は 
%    xd[0] = G * [x0;u0],   ud[0] = u0 
% となります。
%
% 参考 : D2C, D2D, LTIMODELS


% Copyright 1986-2002 The MathWorks, Inc.
