% FIXSCALE   固定小数点ブロック用のスケーリングを記述するベクトルの作成
% 
% この関数は、削除されました。!!!!!!!!!!!!!!!!!
%
% 固定小数点数をもつ"実世界"値を表現するとき、つぎのようにスケーリングを
% 定義することが望まれる場合があります。
%
%                          FixExp
%    Y          = Slope * 2       * Y        + Bias
%     RealWorld                      Integer
%
% FIXSCALE( FixExp, Slope, Bias )は、スケーリングを定義するMATLAB構造体
% を作成し、この構造体を固定小数点ブロックに渡されます。
%
% FIXSCALE( FixExp, Slope )は、バイアスをゼロに設定します。
%
% FIXSCALE( FixExp )は、バイアスをゼロ、勾配を1に設定します。
%
% 参考 : SFIX, UFIX, SINT, UINT, SFRAC, UFRAC, FLOAT.


% Copyright 1994-2002 The MathWorks, Inc.
