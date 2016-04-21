% CLASS   オブジェクトの作成、または、オブジェクトのクラスの出力
%
% C = CLASS(OBJ) は、オブジェクトOBJのクラスを出力します。
% 可能なクラスは、つぎの通りです。
%     double          -- 倍精度浮動小数点数値配列
%                        (これは、従来までのMATLABの行列または配列です)
%     logical         -- 論理配列
%     char            -- キャラクタ配列
%     cell            -- セル配列
%     struct          -- 構造体配列
%     function_handle -- 関数のハンドル
%     int8            -- 8ビット符号付き整数配列
%     uint8           -- 8ビット符号なし整数配列
%     int16           -- 16ビット符号付き整数配列
%     uint16          -- 16ビット符号なし整数配列
%     int32           -- 32ビット符号付き整数配列
%     uint32          -- 32ビット符号なし整数配列
%     <class_name>    -- カスタムオブジェクトクラス
%     <java_class>    -- javaオブジェクトのJavaクラス名
%
% CLASSのその他のすべての利用は、ディレクトリ名 @<class_name>内のファイル
% 名 <class_name>.m のコンストラクタメソッドと共に起動する必要があります。
% さらに、 'class_name' は、CLASSの2番目の引数になります。
%
% O = CLASS(S,'class_name') は、構造体 S からクラス 'class_name' のオブ
% ジェクトを作成します。
%
% O = CLASS(S,'class_name',PARENT1,PARENT2,...) は、親オブジェクト PARENT1, 
% PARENT2, ...等のメソッドとフィールドを継承します。
%
% O = CLASS(struct([]),'class_name',PARENT1,PARENT2,...) は、空の構造体 S を
% 指定し、1つまたは複数の親クラスから継承されるオブジェクトを作成しますが、親
% から継承されない付加的なフィールドはありません。
%
% 参考 ： ISA, SUPERIORTO, INFERIORTO, STRUCT.


%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.8.4.1 $  $Date: 2004/04/28 01:47:13 $
%   Built-in function.
