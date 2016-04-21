% DICOMINFO  DICOM メッセージからメタデータを読む
% INFO = DICOMINFO(FILENAME) は、文字列 FILENAME で指定されている準拠し
% ているDICOM ファイルからメタデータを読み込みます。
%
% INFO = DICOMINFO(FILENAME, 'dictionary', D) は、文字列 D に与えられて
% いるデータ辞書ファイルを使って、DICOM メッセージを読み込みます。D の中
% のファイルは、MATLAB サーチパス上に存在する必要があります。デフォルト
% 値は、dicom-dict.mat です。
%
% 例題:
%
%     info = dicominfo('CT-MONO2-16-ankle.dcm');
%
% 参考：DICOMREAD.



%   Copyright 1993-2002 The MathWorks, Inc.
