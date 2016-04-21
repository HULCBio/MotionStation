% D2C   離散時間 LTI モデルを連続時間に変換
%
%
% SYSC = D2C(SYSD,METHOD) は、離散時間 LTI モデル SYSD と等価な連続時間モデ
% ル SYSC を作成します。文字列 METHOD は、つぎの中から離散化手法を選択します。
%   'zoh'       入力に0次ホールドを適用
%   'tustin'    双1次(Tustin)近似
%   'prewarp'   変換前と変換後で、設定した(臨界)周波数で、応答が一致する制約の
%               もとで、Tustin 近似を行います。 臨界周波数Wc(rad/s)は、
%               D2C(SysD,'prewarp', Wc) で最後に設定されます。
%    'matched'   Matched pole-zero 法(SISO システムのみ) 
% METHOD が省略されると、デフォルトの手法 'zoh' が用いられます。
%
% 参考 : C2D, D2D, LTIMODELS


% Copyright 1986-2002 The MathWorks, Inc.
