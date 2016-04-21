% IDARX/IV4 は、多変数 ARX モデルに関する適切なIV-推定を計算します。
%
%   MODEL = IV4(DATA,Mi)
%
%   MODEL: 推定した共分散と構造に関する情報を基にARX モデルの推定
%   A(q) y(t) = B(q) u(t-nk) + v(t)
%   MODEL の厳密な書式については、HELP IDARX を参照してください。
%
%   DATA: 入出力データと IDDATA オブジェクト。HELP IDDATA を参照してくだ
%         さい。 
%
%   Mi  : 次数を設定する IDARX オブジェクト。help IDARX を参照してくださ
%         い。
%
% アルゴリズムに関連したいくつかのパラメータは、
% 
%   MODEL = IV4(DATA,Mi'MaxSize',MAXSIZE)
% 
% でアクセスされます。ここで、MAXSIZE は、メモリとスピードのトレードオフ
% を設定するものです。マニュアルを参照してください。
% プロパティの名前と値を組として使用する場合、組毎に任意の順番で設定でき
% ます。省略したものは、デフォルト値が使われます。
% MODEL プロパティ 'FOCUS' と 'INPUTDELAY' は、
% 
%   M = IV4(DATA,Mi,'Focus','Simulation','InputDelay',[3 2]);
% 
% のようにプロパティ名/値として設定できます。
% 詳細は、IDPROPS ALGORITHM と IDPROPS IDMODEL を参照してください。
%    
% 参考： ARX, ARMAX, BJ, N4SID, OE, PEM.



%   Copyright 1986-2001 The MathWorks, Inc.
