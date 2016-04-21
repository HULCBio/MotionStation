% CDFWRITE   CDFファイルにデータの書き出し
% 
% CDFWRITE(FILE, VARIABLELIST) は、FILE によって指定された名前の
% CDFファイルに書き出します。VARIABLELIST は、CDF変数名(文字)と
% 対応するCDF変数値から成る順序に対応したセル配列です。変数に対して
% 複数のレコードを書き出すには、セル配列に変数の値を入れてください。
% セル配列中の各要素は、レコードを意味します。
%
% CDFWRITE(..., 'PadValues', PADVALS) は、与えられた変数名に対して
% 値を埋め込んだものを書き出します。PADVALS は、変数名(文字)と対応
% する埋め込み値から成る順序に対応したセル配列です。区域外のレコード
% がアクセスされるとき、埋め込み値は変数に関連するデフォルト値です。
% PADVALS に出てくる変数名は、VARIABLELIST にも出てこなければなりま
% せん。
%
% CDFWRITE(..., 'GlobalAttributes', GATTRIB) は、CDFに対するグローバル
% meta-dataとして構造体 GATTRIB を書き出します。構造体の各フィールドは、
% グローバル属性の名前です。各フィールドの値は、属性の値を含みます。
% 属性に対して複数の値を書き出すには、フィールド値はセル配列でなければ
% なりません。
%
% MATLAB内で不正なグローバル属性名を指定するためには、属性の構造体の
% 中に、"CDFAttributeRename"と呼ばれるフィールドを作成してください。
% "CDFAttribute Rename" は、順序に対応したセル配列の値を持たなければ
% なりません。GlobalAttributes 構造体と CDF に書き出される属性に対応
% する名前にリストされるように、オリジナルの属性の名前の順序に対応した
% 構成になります。
%
% CDFWRITE(..., 'VariableAttributes', VATTRIB) は、CDFに対する
% meta-dataの変数として構造体 VATTRIB を書き出します。構造体の
% 各フィールドは、変数の属性の名前です。各フィールドの値は、m が
% 属性の変数の数とすると、m×2 のセル配列です。セル配列の最初の要素は
% 変数名で、2番目の要素は、変数に対する属性の値である必要があります。
%
% MATLAB内で不正な変数の属性名を指定するためには、属性の構造体内に 
% "CDFAttributeRename" と呼ばれるフィールドを作成してください。
% "CDFAttributeRename" フィールドは、順序に対応したセル配列の値を
% もたなければなりません。VariableAttributes 構造体と CDF に書き出さ
% れる対応する属性名にリストされるように、オリジナルの属性の名前の
% 順序に対応した構成になります。名前を変更してCDF 変数の変数の属性を
% 指定する場合、VariableAttributes 構造体の変数名は、名前を変更した
% 変数と同じでなければなりません。
%
% CDFWRITE(..., 'WriteMode', MODE) は、MODE が 'overwrite' か 'append'
% のどちらかで、指定された変数か、またはファイルが既に存在する場合に、
% CDF に付加かするかどうかを示します。デフォルトは CDFWRITE が変数と
% 属性を付加しないことを示す 'overwrite' です。
%
% CDFWRITE(..., 'Format', FORMAT) は、FORMAT が 'multifile' か 
% 'singlefile' のどちらかで、データを multi-file CDF として書き出す
% かどうかを示します。multi-file CDF では、各変数は、N を CDF に書き
% 出す変数の数とすると、 *.vN ファイルに格納されます。デフォルトは、
% CDFWRITE が単一の CDF に書き出すことを示す 'singlefile' です。
% 'WriteMode' が 'Append' に設定された場合、'Format' オプションは
% 無視され、既に存在する CDF の形式が使われます。
%
% 注意: CDFWRITE は、CDF ファイルに書き込みをする場合、テンポラリファイルを
% 作成します。このファイルのターゲットディレクトリとカレントの作業ディレクトリ
% は、いずれも書き込み可能である必要があります。
%
% 例題:
%
%      >> cdfwrite('example', {'Longitude', 0:360});
%
%         値が [0:360] の 'Longitude' の変数を含むファイル 'example.cdf'
%         を書き出します。
%
%      >> cdfwrite('example', {'Longitude', 0:360, 'Latitude', 10:20}, ...
%                  'PadValues', {'Latitude', 10});
%
%         区域外のレコードのアクセスのすべてに対して10の埋め込み値をもつ
%         変数 'Latitude' とともに、'Longitude' と 'Latitude' の変数を
%         含むファイル 'example.cdf' を書き出します。
%
%      >> varAttribStruct.validmin = {'longitude' [10]};
%      >> cdfwrite('example', {'Longitude' 0:360}, 'VariableAttributes', ...
%                  varAttribStruct);
%
%         値10である 'validmin' の変数の属性と、[0:360] の値 をもつ
%         'Longitude' の変数を含むファイル 'example.cdf' を書き出します。
%
% 参考 : CDFREAD, CDFINFO, CDFEPOCH.



%   binky
%   Copyright 1984-2002 The MathWorks, Inc.
