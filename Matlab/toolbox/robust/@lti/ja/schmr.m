% SCHMR Schur法による平衡化打ち切り (不安定プラント)
%
% [SS_M,TOTBND,HSV] = SCHMR(SS_,MRTYPE,NO)、または、
% [AM,BM,CM,DM,TOTBND,HSV]=SCHMR(A,B,C,D,MRTYPE,NO) は、つぎの条件を満足
% するG(s):=(a,b,c,d)に関してSchur法によるモデル低次元化を実行します。
% 
% 誤差(Ghed(s) - G(s))の無限大ノルム <= 2(n-k)までのハンケル特異値の和
% 
% 不安定なG(s)に対して、アルゴリズムはまず安定部と不安定部にG(s)を分割し
% ます。
%
% "MRTYPE"の選択によって、つぎのオプションがあります:
%
%    1). mrtype = 1  --- no: 低次元化モデルのサイズ"k"
%    2). mrtype = 2  --- トータルの誤差が"no"より小さくなるk次のモデルを
%                        算出。
%    3). mrtype = 3  --- 全てのハンケル特異値を表示し、"k"の入力を促しま
%                        す(この場合、"no"を指定する必要はありません)。
%
% TOTBND = 誤差範囲, HSV = ハンケル特異値



% $Revision: 1.6.4.2 $
% Copyright 1988-2002 The MathWorks, Inc. 
