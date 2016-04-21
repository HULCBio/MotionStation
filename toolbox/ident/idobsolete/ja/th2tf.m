% TH2TF  THETA フォーマットから伝達関数への変換
%   
%         [NUM, DEN] = TH2TF(TH, IU)
%
%   TH  : THETA フォーマットで定義されたモデル(THETA 参照)
%   IU  : 対象とする入力番号(デフォルトは1)。
%         雑音源 ni は、入力番号 -ni と指定します。
%   NUM : 伝達関数の分子多項式。多変数モデルの場合、NUM の k 行目が入力
%         番号 IU から出力番号 k までの伝達関数となります。
%   DEN : 伝達関数の分母多項式(すべての出力に対して同じになります)。
%
% NUM と DEN は、Control System Toolbox の標準形式です(連続時間モデルと
% 離散時間モデルに対して共通のフォーマットです)。
%
% 参考:    TH2FF, TH2POLY, TH2SS, TH2ZP

%   Copyright 1986-2001 The MathWorks, Inc.
