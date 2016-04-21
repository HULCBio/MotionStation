% WAVREAD   Microsoft WAVE (".wav")サウンドファイルの読み込み
% 
% Y = WAVREAD(FILE)は、文字列FILEで指定されたWAVEファイルを読み込み、サ
% ンプリングされたデータをYに出力します。拡張子が指定されていない場合は、
% ".wav"を付け加えます。振幅値は、範囲[-1,+1]です。
%
% [Y,FS,NBITS] = WAVREAD(FILE)は、ヘルツ単位でサンプリングレート(FS)を出
% 力し、ファイル内のデータを符号化するために使うサンプルあたりのビット数
% (NBITS)を出力します。
%
% [...] = WAVREAD(FILE,N)は、ファイル内の各チャンネルから、最初のN個のサ
% ンプルのみを出力します。
% 
% [...] = WAVREAD(FILE,[N1 N2])は、ファイル内の各チャンネルのN1からN2まで
% のサンプルのみを出力します。
% 
% SIZ = WAVREAD(FILE,'size')は、実際のオーディオデータの代わりに、ファイ
% ル内にあるオーディオデータのサイズを、ベクトルSIZ = [samples channels]
% として出力します。
%
% [Y,FS,NBITS,OPTS] = WAVREAD(...)は、WAVファイル内に含まれる付加的な情
% 報を構造体OPTSに出力します。この構造体の内容は、ファイル毎に異なります。
% 一般に使われる構造体のフィールド名は、'.fmt'(オーディオフォーマット情
% 報)と'.info'(サブジェクトタイトル、コピーライト等を記述するテキスト)で
% す。
%
% サンプルあたり32ビットまでのマルチチャンネルデータをサポートしています。
% 
% 注意：このファイルリーダは、Microsoft PCMデータフォーマットのみを
%       サポートしています。wave-list データは、サポートしていません。
%
% 参考：WAVWRITE, AUREAD, AUWRITE.


%   Author: D. Orofino
%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 5.28 $  $Date: 2002/05/30 20:42:03 $

%   Copyright 1984-2004 The MathWorks, Inc.
