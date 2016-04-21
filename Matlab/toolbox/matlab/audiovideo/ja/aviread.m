% AVIREAD     AVI ファイルの読み込み 
% MOV = AVIREAD(FILENAME) は、MATLABムービー構造体 MOV 内の
% AVI ムービー FILENAME を読み込みます。FILENAME に拡張子が含まれ
% ていない場合は、'.avi' が使われます。MOV は2つのフィールド、"cdata"と
% "colormap"をもちます。フレームがトゥルーカラーイメージである場合は、
% MOV.cdata は Height-Width-3 の大きさで、MOV.colormap は空になりま
% す。フレームがインデックス付きイメージの場合は、MOV.cdata のフィールド
% は Height 行 Width 列の大きさで、MOV.colormap は M 行 3 列の大きさで
% す。UNIXの場合は、FILENAME は非圧縮のAVIファイルでなければなりま
% せん。
%  
% MOV = AVIREAD(...,INDEX) は、INDEX で指定されたフレームのみを読み
% 込みます。INDEX は、ビデオストリーム内のインデックス配列、または1つの
% インデックスのいずれかです。ここで、最初のフレームのインデックスは1です。
%
% サポートされているフレームタイプは、8 ビット (インデックス付き、または、
% グレースケール)、16 ビットグレースケール、または、 24 ビット 
% (トゥルーカラー) フレームです。
%
% 参考：AVIINFO, AVIFILE.

% $Revision: 1.1.6.3 $ $Date: 2004/04/28 01:45:09 $
%   Copyright 1984-2001 The MathWorks, Inc.
