% WAVWRITE   Microsoft WAVE (".wav")サウンドファイルへの書き出し
%
% WAVWRITE(Y,FS,NBITS,WAVEFILE) は、データYを、ファイル名WAVEFILEで指定さ
% れたWindows WAVE ファイルに、サンプルレートFS、ビット数NBITSで書き出し
% ます。NBITSは、8, 16, 24, 32ビットでなければなりません。Stereo データは、
% 2列の行列で指定してください。NBITS < 32 に対しては、範囲 [-1,+1] 以外の
% 振幅値は切り取られます。
%
% WAVWRITE(Y,FS,WAVEFILE) は、NBITS = 16ビットを仮定しています。
% WAVWRITE(Y,WAVEFILE) は、NBITS = 16ビット、FS = 8000Hzを仮定しています。.
%
% 8、16、24ビットファイルは、タイプ1 整数PCMです。32ビットファイルは、
% タイプ3正規化浮動小数点数として書かれています。
%
% 参考 ： WAVREAD, AUWRITE.


%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.1.6.2 $  $Date: 2004/04/28 01:45:19 $
