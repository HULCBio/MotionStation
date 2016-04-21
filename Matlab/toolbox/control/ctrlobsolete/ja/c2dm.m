% C2DM   連続 LTI システムを離散時間 LTI に変換
%
% [Ad,Bd,Cd,Dd] = C2DM(A,B,C,D,Ts,'method') は、連続時間状態空間システム
% (A, B, C, D)を'method'で定義した方法を使って、離散時間に変換します。
% 'method'には、つぎのいずれかを定義することができます。
% 
%  'zoh'         入力にゼロ次ホールドを仮定して離散時間に変換します。
%  'foh'         入力に一次ホールドを仮定して離散時間に変換します。
%  'tustin'      微係数への双一次(Tustin)変換を使って、離散時間に変換します。
%  'prewarp'     ある特定の周波数で、変換前と変換後を一致させる制約のもとで、双
%                一次(Tustin)近似を使って、離散時間に変換します。付加的
%                な引数として臨界周波数を設定します。たとえば、
%                C2DM(A,B,C,D,Ts,'prewarp', Wc) として使います。
%  'matched'     matched pole-zero 法を使って、SISO システムを離散時間に
%                変換します。
%
% [NUMd,DENd] = C2DM(NUM,DEN,Ts,'method') は、連続時間多項式伝達関数 
% G(s) = NUM(s)/DEN(s) を,'method'に設定した方法を使って、離散時間多項式
% 伝達関数 G(z) = NUMd(z)/DENd(z) に変換します。
%
% 参考 : C2D, D2CM.


%   Clay M. Thompson  7-19-90
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.5.4.1 $  $Date: 2003/06/26 16:07:29 $
