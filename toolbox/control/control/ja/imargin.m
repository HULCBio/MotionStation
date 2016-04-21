% IMARGIN   内挿を使って、ゲイン余裕と位相余裕を出力
%
% [Gm,Pm,Wcg,Wcp] = IMARGIN(MAG,PHASE,W) は、Bode 応答のゲインと位相、
% 周波数ベクトル MAG、PHASE、W を与えて、線形システムからゲイン余裕 Gm と
% 位相余裕 Pm 、関連した周波数、WcgとWcp を出力します。IMARGIN は、線形
% スケールでゲイン値を、度単位で位相値を考えています。
%
% 左辺の引数を設定しない IMARGIN(MAG,PHASE,W) 場合、垂直線でマーク付け
% されたゲインと位相余裕を示す Bode 応答を表示します。
%
% IMARGIN は、連続システム、離散システム共に使用可能です。真のゲイン余裕
% と位相余裕に近似するために、周波数点間に内挿を使用します。システムが、
% LTIモデルの場合、MARGIN を使って、より精度の高いものを出力することが
% できます。
%
% IMARGIN の例題：
%     [mag,phase,w] = bode(a,b,c,d);
%     [Gm,Pm,Wcg,Wcp] = imargin(mag,phase,w)
%
% 参考：BODE, MARGIN, ALLMARGIN.


%   Clay M. Thompson  7-25-90
%   Revised A.C.W.Grace 3-2-91, 6-21-92
%   Revised A.Potvin 10-1-94
%   Revised P. Gahinet 10-99
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.3.4.1 $  $Date: 2003/06/26 16:04:15 $
