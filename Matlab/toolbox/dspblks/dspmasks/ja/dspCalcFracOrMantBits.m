% numBits = dspCalcFracOrMantBits(blk,dtObject,maxVal)
%    blk      : ビット数を計算するためのブロック
%    dtObject : ブロックに対するクラスオブジェクト(sfix(), uint(), など)
%    maxVal   : fixptbestprec をコールするための最大値。デフォルトは-1。
%
% この関数は、ブロックのマスクデータタイプパラメータが 'Fixed-point' または
% 'User-defined' のとき、ビットの数、または分数、または仮数を計算します。
% 
% ブロックが固定小数点データタイプで、'Best precision' に設定されている
% 場合、maxVal を設定しなければなりません。
%
% 注意: この関数は、以下のパラメータがブロックにあるものと仮定します。:
%   
%   fracBitsMode : 2つの選択をもつポップアップ: 'Best precision' と 
%                  'Userdefined'
%   numFracBits  : fracBitsMode が 'User-defined' のときに有効なエディット
%                  ボックス
%   
% 注意: これは、DSP Blocksetのマスクユーティリティ関数です。通常の目的で
%       使用される関数として意図したものではありません。


%   Copyright 1995-2002 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2003/07/22 21:04:22 $
