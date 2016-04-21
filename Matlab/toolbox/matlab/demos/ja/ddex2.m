% DDEX2  DDE23に対する例題2
%
% この例題は、t = 600から始まる周辺圧Rが指数関数敵に1.05から0.84に減少
% するとき、J.T. Ottesen, Modelling of the Baroflex-Feedback Mechanism 
% With Time-Delay, J. Math. Biol., 36 (1997)による心臓血管モデルを解きます。
%
% 例題は、あらかじめ知られている点 (t = 600)において、低次の微係数における
% 不連続に関してソルバに伝えるために、'Jumps'オプションを利用する方法を
% 示しています。 'Jumps'を使う代わりに、この例題は、2つの部分に分ける
% ことによって解くことができます。
%       sol = dde23(@ddex2de,tau,history,[0, 600],[],p);
%       sol = dde23(@ddex2de,tau,sol,[600, 1000],[],p);
% [0, 600] における解の構造体SOLは、t = 600において積分を再開するための
% 履歴として利用されます。2回目の呼び出しにおいて、DDE23 は [0 1000]の
% すべてにおいて解が利用できるようにSOLを拡張します。あらかじめて知ら
% れている点において低次の微係数において不連続が発生したときは、'Jumps' 
% オプションを使った方が良いでしょう。イベント関数を使って不連続を探さ
% なければならないときは、不連続点において再開する必要があります。
%
% 参考 ： DDE23, DDESET, @.


%   Jacek Kierzenka, Lawrence F. Shampine and Skip Thompson
%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.2.4.1 $  $Date: 2004/04/28 01:48:20 $
