% FIXSLOPE   固定小数点ブロック用のスケーリングを記述するベクトルを作成
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
% FIXSLOPE( Slope, Bias )は、
% 
%      FixExp = 0;
% 
% と設定したスケーリングを定義するMATLAB構造体を生成し、固定小数点ブロッ
% クに転送されます。
%
% FIXSLOPE( Slope )は、バイアスをゼロに設定します。  
%
% 参考 : FIXRADIX, SFIX, UFIX, SINT, UINT, SFRAC, UFRAC, FLOAT.


% Copyright 1994-2002 The MathWorks, Inc.
