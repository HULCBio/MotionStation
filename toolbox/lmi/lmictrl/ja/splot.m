% splot(sys,choice,xrange)         (連続時間)
% splot(sys,T,choice,xrange)       (離散時間)
%
% システムSYSの周波数応答や時間応答をプロットする関数です。
%
% 入力:
%   SYS         SYSTEM行列(LTISYSを参照)。
%   CHOICE      プロットする対象を設定する文字列。
%                  'bo'  :   Bodeプロット
%                  'sv'  :   特異値プロット
%                  'ny'  :   ナイキストプロット(SISO)
%                  'li'  :   Lin-logナイキストプロット(SISO)
%                  'ni'  :   ブラック/ニコルス線図 (SISO)
%
%                  'st'  :   ステップ応答
%                  'im'  :   インパルス応答
%                  'sq'  :   矩形波信号に対する応答
%                  'si'  :   正弦波信号に対する応答
%   XRANGE      ユーザが指定した周波数、または、時間のベクトル(オプショ
%               ン)。オプション'sq'と'si'に対して、XRANGEは、単純に入力
%               信号の区間です。
%   T           秒単位のサンプリング間隔(離散時間システム)。
%
% 参考：    LTISYS.



% Copyright 1995-2002 The MathWorks, Inc. 
