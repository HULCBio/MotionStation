% LQG   連続時間線形二次形式Gaussian制御設計
%
% [SS_F] = LQG(SS_,W,V)または[AF,BF,CF,DF] = LQG(A,B,C,D,W,V)は、"分離原理"
% を基に、評価関数
%                     T
%    J    = lim E{ int   |x' u'| W |x| dt} , W = |Q  Nc| 
%     LQG   T-->inf   0            |u|           |Nc' R|
%    
% が最小化され、プラント
% 
%                       dx/dt = Ax + Bu + xi
%                           y = Cx + Du + th
%
% において、白色ノイズ雑音{xi}および{th}が、
%
%           E{|xi| |xi th|'} = V delta(t-tau), V =  |Xi  Nf|
%             |th|                                  |Nf' Th|
%
% のように強度Vの相互相関関数をもつ、線形二次形式Gaussian最適コントローラ
% を計算します。 
% 
% LQG最適コントローラF(s)は、SS_Fまたは(af,bf,cf,df)に出力されます。
% 標準の状態空間型は、"branch"により求められます。



% Copyright 1988-2002 The MathWorks, Inc. 
