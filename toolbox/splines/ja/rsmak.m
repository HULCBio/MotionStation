% RSMAK   rB-型の有理スプラインの組立て
%
% RSMAK(KNOTS,COEFS) は、入力によって指定された有理スプラインの
% rB-型を出力します。
%
% 有理スプラインのB-型ととして標識されること、すなわち、分母がスプライン
% の最終要素によって与えられ、分子が残る要素で記述されるような有理スプ
% ラインであることを除いて、これは厳密に SPMAK(KNOTS,COEFS) の出力です。
% 同様に、そのターゲットの次元は、SPMAK(KNOTS,COEFS) の出力に対しての
% 次元よりも小さくなります。
%
% 特に、入力の係数は、いくらかの d>0 に対して(d+1)要素のベクトル値で
% なければならず、N次元の値をもったものにはなりません。
%
% 例えば、spmak([-5 -5 -5 5 5 5],[26 -24 26]) は、区間 [-5 .. 5] で
% 多項式 t |-> t^2+1 のB-型を与える一方、spmak([-5 -5 -5 5 5 5], [1 1 1]) 
% は、定数関数1のB-型を与えます。また、コマンド
%
%      runge = rsmak([-5 -5 -5 5 5 5],[1 1 1; 26 -24 26]);
%
% は、等間隔のサイトでの多項式補間に関するRungeの例題で有名な有理関数
% t |-> 1/(t^2+1) に対する区間 [-5 .. 5] でのrB-型を与えます。
%
% RSMAK(KNOTS,COEFS,SIZEC) は、COEFS が後に続く要素数1の次元をもつときに
% 使用されます。この場合、SIZEC が COEFS の意図される大きさを与えるベク
% トルでなければなりません。特に SIZEC(1) は、実際の COEFS の最初の次元で
% なければなりません。従って、SIZEC(1)-1 は、ターゲットの次元です。
%   
% rB-型は、c(:,i) が NURBS の対応する制御点であり、また、w(i) がその対応
% する重みであるときに、rB-型の標準的な係数が [w(i)*c(:,i);w(i)] の形を
% もつという意味において、NURBS のバージョンと同じです。
%
% RSMAK(OBJECT,varargin) は、文字列 OBJECT で指定された特定の幾何学的な
% 形状を出力します。例えば、
%
% rsmak('circle',radius,center) は、与えられた半径(デフォルト1)と中心
% (デフォルト (0,0))をもつ円を記述する2次の有理スプラインを与えます。
%
% rsmak('cone',radius,height) は、先端が (0,0,0) でz-座標上に中軸をもつ
% 与えられた半径(デフォルト1)と半分の高さ(デフォルト1)の対称な円錐を
% 記述する2次の有理スプラインを与えます。
%
% rsmak('cylinder',radius,height) は、z-座標上に中軸をもつ与えられた半径
% (デフォルト1)と高さ(デフォルト1)の円柱を記述する2次の有理スプラインを
% 与えます。
%
% rsmak('southcap',radius,center) は、与えられた半径(デフォルト1)と中心
% (デフォルト (0,0,0))をもつ球の南側の6分の1を与えます。
%
% transf によって指定されたアフィン(affine)変換の結果として生じた幾何学的
% なオブジェクトを取り出すには、fncmb(rs,transf) を使用してください。
% 例えば、以下は 'southcap' 自身と、その回転のうちの2つおよびその鏡映に
% よって与えられるような球の2/3のプロットを生成します。
%
%      southcap = rsmak('southcap');
%      xpcap = fncmb(southcap,[0 0 -1;0 1 0;1 0 0]);
%      ypcap = fncmb(xpcap,[0 -1 0; 1 0 0; 0 0 1]);
%      northcap = fncmb(southcap,-1);
%      fnplt(southcap), hold on, fnplt(xpcap), fnplt(ypcap), fnplt(northcap)
%      axis equal, shading interp, view(-115,10), axis off, hold off
%
% 参考 : RSBRK, RPMAK, PPMAK, SPMAK, FNBRK.


%   Copyright 1999-2003 C. de Boor and The MathWorks, Inc.
