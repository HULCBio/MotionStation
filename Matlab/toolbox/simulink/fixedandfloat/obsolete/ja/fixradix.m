% FIXRADIX   固定小数点ブロック用のスケーリングを記述するベクトルを作成
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
% FIXRADIX( FixExp ) は、つぎのパラメータを使って、MATLAB構造体を定義し
% ます。
%      Slope = 1
%      Bias  = 0
% この構造体は、固定小数点に渡されます。
% 
% 参考 : FIXSLOPE, SFIX, UFIX, SINT, UINT, SFRAC, UFRAC, FLOAT.


% Copyright 1994-2002 The MathWorks, Inc.
