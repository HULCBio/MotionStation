% IMP2SS   インパルス応答によるシステム同定(Kungの特異値分解アルゴリズム)
%
% [A,B,C,D,TOTBND,SVH] = IMP2SS(Y)
% [A,B,C,D,TOTBND,SVH] = IMP2SS(Y,TS,NU,NY,TOL)
% [SS_,TOTBND,SVH] = IMP2SS(IMP_)
% [SS_,TOTBND,SVH] = IMP2SS(IMP_,TOL) 
% 関数IMP2SSは、与えられたインパルス応答の近似的な状態空間実現を出力します。
%                 IMP_=MKSYS(Y,TS,NU,NY,'imp')
% 
% これは、S. Kung(Proc. Asilomar Conf. on Circ. Syst. & Computers, 1978)に
% より提唱されたHankel特異値分解を使っています。連続系の実現は、TSが正の場
% 合、逆Tustin変換を使って計算されます。それ以外では、離散系の実現が出力さ
% れます。
%
%  入力:  Y --- 行単位のインパルス応答H1,...,HN
%                 Y=[H1(:)'; H2(:)'; H3(:)'; ...; HN(:)']
%  オプション入力:
%           TS  ---  サンプリング間隔(デフォルトTS=0)
%           NU  ---  入力数 (デフォルトNU=1)
%           NY  ---  出力数 (デフォルトNY= size(Y)*[1;0]/nu)
%           TOL ---  誤差範囲のHinfnorm(デフォルトTOL=0.01*S(1))
%  出力: (A,B,C,D) 離散状態空間実現
%         TOTBND  無限大ノルムの誤差範囲2*Sum([S(NX+1),S(NX+2),...])
%         SVH  ハンケル特異値[S(1);S(2);... ]



% Copyright 1988-2002 The MathWorks, Inc. 
