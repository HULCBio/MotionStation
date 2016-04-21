% D2CM   離散 LTI システムを連続時間に変換
%
% [Ac,Bc,Cc,Dc] = D2CM(A,B,C,D,Ts,'method') は、'method'で設定した方法を
% 使って、離散時間状態空間システムを連続時間システムに変換します。
% 
%  'zoh'         入力にゼロ次ホールドを仮定して連続時間に変換します。
%  'tustin'      微係数への双一次(Tustin)変換を使って、連続時間に変換します。
%  'prewarp'     ある特定の周波数で、変換前と変換後を一致させる制約のもとで、
%                双一次(Tustin)近似を使って、連続時間に変換します。付加的な
%                引数として臨界周波数を設定します。たとえば、
%                D2CM(A,B,C,D,Ts,'prewarp',Wc) として使います。
%  'matched'     matched pole-zero 法を使って、SISO システムを連続時間に
%                変換します。
% 
% [NUMc,DENc] = D2CM(NUM,DEN,Ts,'method') は、離散時間多項式伝達関数 
% G(z) = NUM(z)/DEN(z) を'method' で設定した方法を使って、連続時間 
% G(s) = NUMc(s)/DENc(s) に変換します。
%
% 注意： 'foh' は、使用できません。
%
% 参考 : D2C, C2DM.


%   Clay M. Thompson  7-19-90
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.5.4.1 $  $Date: 2003/06/26 16:07:33 $
