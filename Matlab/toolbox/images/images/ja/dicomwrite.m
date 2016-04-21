% DICOMWRITE   DICOM ファイルとしてイメージを書き込む
% 
% DICOMWRITE(X, FILENAME) は、FILENAME と名づけられたファイルに、バイ
% ナリ、グレースケール、またはトゥルーカラーイメージ X を書き込みます。
%
% DICOMWRITE(X, MAP, FILENAME) は、カラーマップ MAP を使ってインデック
% ス付きイメージ X を書き込みます。
%
% DICOMWRITE(..., PARAM1, VALUE1, PARAM2, VALUE2, ...) は、DICOMファイ
% ルの書き込みに影響するパラメータか、またはDICOMファイルに書き込むた
% めのオプションのメタデータを指定します。PARAM1 は、メタデータの属性
% 名か、またはDICOMWRITE の指定オプションを含んだ文字列です。VALUE1 は、
% 属性、またはオプションに対応する値です。
%
% 条件を満たす属性名は、データ辞書 dicom-dict.txt 内にリストされてい
% ます。さらに、以下の DICOM 指定オプションが利用可能です。:
%
%   'Endian'           ファイルに対する byte-ordering: 
%                      'Big' または 'Little'(デフォルト)
%
%   'VR'               値の表現をファイルに書き込むかどうか:  
%                      'Explicit' または 'Implicit'(デフォルト)
%
%   'CompressionMode'  イメージに格納するときに使われる圧縮タイプ: 
%                      'JPEG lossy', 'RLE' または 'None' (デフォルト)
%
%   'TransferSyntax'   Endian と VR モードで指定される DICOM UID
%
% 注意: デフォルトでは、DICOMWRITE は、VR を 'Implicit'、byte-ordering
% を little-endian、圧縮モードをなしとして、記号化されたファイルを作成
% します。上記にリストされるオプションの1つかそれ以上が DICOMWRITE に
% 与えられると、デフォルトの設定を無効にします。TransferSyntax パラ
% メータが与えられた場合、使用される値は一つだけです。それ以外では、
% 指定されていれば CompressionMode パラメータが使われます。最終的には、
% VR と Endian パラメータが使われます。Endian を 'Big' の値にし、VR を
% 'Implicit' の値として指定することはできません。
%
% DICOMWRITE(..., META_STRUCT, ...) は、構造体により、オプションのメタ
% データかファイルに対するオプションを指定します。構造体のフィールド名
% は、上記に示される構文内のパラメータ文字列に類似しており、フィールド
% 値はパラメータ値です。
%
% DICOMWRITE(..., INFO, ...) は、DICOMINFO によって作られたメタデータ
% 構造体 INFO を使用します。
%
% STATUS = DICOMWRITE(...) は、メタデータパラメータについての情報を出
% 力し、オプションは DICOMWRITE に与えられるか、何も指定されない場合は
% 空になります。
%
% メタデータの構造体か、 DICOMINFO の結果としてパラメータ値をペアで指
% 定する場合、DICOMWRITE に影響しないパラメータを参照することができま
% す。STATUS は、これらの使われていないパラメータを含む構造体で、以下
% のフィールドをもちます。:
%
%   'dicominfo_fields'  このフィールド内の値は、ファイルの書き込み方法
%                       には影響しない、DICOMINFO で返された特定のメタ
%                       データです。
%
%   'wrong_IOD'         このフィールドは、イメージの書き込みのタイプに
%                       関係しないメタデータ属性を含みます。
%
%   'not_modifiable'    これらの値は書き込まれたイメージに対して有効な
%                       メタデータフィールドですが、ユーザ指定の値を含
%                       むことはできません。
%
% 参考:  DICOMINFO, DICOMREAD.


%   Copyright 1993-2002 The MathWorks, Inc.
%   $Revision: 1.1 $  $Date: 2003/04/18 17:15:54 $
