% SCHBAL Schur法による平衡化打ち切り (安定プラント)
%
% [SS_H,AUG,HSV,SLBIG,SRBIG] = SCHBAL(SS_,MRTYPE,NO)、または、
% [AHED,BHED,CHED,DHED,AUG,HSV,SLBIG,SRBIG]=SCHBAL(A,B,C,D,MRTYPE,NO) は、
% つぎの条件を満足するG(s):=(a,b,c,d)に関してSchur法によるモデル低次元化
% を実行します。
% 
%    誤差(Ghed(s) - G(s))の無限大ノルム <= 
%                 2(n-k)までのハンケル特異値の和
%
%         (ahed,bhed,ched,dhed) = (slbig'*a*srbig,slbig'*b,c*srbig,d)
%
% "MRTYPE"の選択により、つぎのオプションがあります。:
%
%  1). mrtype = 1  --- no: 低次元化モデルのサイズ"k"
%  2). mrtype = 2  --- トータルの誤差が"no"より小さくなるk次のモデルを算
%                      出。
%  3). mrtype = 3  --- 全てのハンケル特異値を表示し、"k"の入力を促します。
%                      (この場合、"no"を指定する必要はありません。)
%
% AUG = [削除した状態の数, 誤差範囲], HSV = ハンケル特異値

% Copyright 1988-2002 The MathWorks, Inc. 
