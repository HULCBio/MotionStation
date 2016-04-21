% FIXMULT LMI/乗数μ解析
%
% [mu,sysm,syss] = fixmult(sys1,k,n)、または、
% [mu,am,bm,cm,dm,as,bs,cs,ds]=fixmult(a,b,c,d,k,n) は、
% G(s) := [A,B,C,D] の実/複素構造化特異値に関するスカラの上界MUと、関連
% する固定次数最適対角乗数(スケーリング行列)M(s)を計算します。乗数MUの上
% 界は、つぎの式を解くことで計算されます。
%
%        min MU
%         Mi
%            s.t. hinfnorm(G(s)) <= 1 ここで、
%        G(s) := blt( M(s) * blt( G(s)/MU ))
%        M(s) := diag(M1(s)*I, ... , Mn(s)*I).
% blt(X) = (I-X)/(I+X) と Mi(s) (for i=1,...,n) は、プロパーかつ有理でな
% ければいけません。また、分母多項式DEN(デフォルトは1)がreal(M(jw))>=0
% でなければいけません。
%
% この関数は、ACC '94 の Ly, Safonov と Chiang のLMI形式を用いて乗数を計算
% することに対し、LMI Lab を利用します。
%
% 入力 :
%  [A,B,C,D]、または、SYS --- G(s)の状態空間表現
% オプション入力 :
%  k --- kのn行目は、つぎのように不確かさの構造を指定します。
%        k(i,1) --- 実数に対して-1、複素数に対して1
%        k(i,2) --- i番目の不確かさのサイズ (正方ブロック)
%        k(i,3) --- 繰り返しブロック
%  n --- i番目の乗数の次数で、偶数でなければいけません。
%
% 注意 : つぎの構造的不確かさが利用できます。
%        実スカラ, 繰り返し実スカラ
%        複素スカラ, 繰り返し複素スカラ
%        複素フルブロック
%
% 出力 :
%  MU --- G(s)のスカラ構造化特異値
%  [AM,BM,CM,DM] 乗数 M(s) := diag(M1(s)*I,...,Mn(s)*I) の状態空間表現
%  [AS,BS,CS,DS] 最適に"スケーリングされたシステム"の状態空間表現
%
% Author : J. H. Ly   5/95
% Updated by R. Y. Chiang 2/96

% Copyright 1988-2002 The MathWorks, Inc. 
