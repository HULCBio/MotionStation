% DSPBUFST   DSP BlocksetのBufferブロックやUnbufferブロックに対する
%            サンプル時間を計算
%
% DSPBUFST(Ts,N,Ko) は、ベースサンプルレートが Ts、バッファ長が N、初期
% アンバッファオフセット Ko のBuffer/Unbufferブロックに対して、2行2列の
% 行列で、最初の行は、速い方の(ベース)サンプルレートとオフセットで、
% 2番目の行は、遅い方のサンプルレートとオフセットになります。
%	
% この関数は、DSP Blocksetの中の削除されたBufferブロックとUnbufferブロック
% のマスクの中で使われたものです。


%	Copyright 1995-2002 The MathWorks, Inc.
%	$Revision: 1.6.6.1 $ $Date: 2003/07/22 21:03:35 $ 
