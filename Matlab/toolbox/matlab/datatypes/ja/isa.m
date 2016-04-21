%ISA    与えられたクラスのオブジェクトの検出
% ISA(OBJ,'class_name') は、OBJのクラスが'class_name' であるか、またはクラス
% が 'class_name' を継承する場合は true を、そうでなければ false を出力します。
%
% 'class_name' の取り得る値は、つぎのものです。
%     double          -- 倍精度浮動小数点数値配列
%                        (これは、古典的なMATLAB行列または配列です)
%     logical         -- 論理配列
%     char            -- キャラクタ配列
%     single          -- 単精度浮動小数点数値配列
%     float           -- 倍精度または単精度浮動小数点数値配列
%     int8            -- 8ビット符号付き整数配列
%     uint8           -- 8ビット符号なし整数配列
%     int16           -- 16ビット符号付き整数配列
%     uint16          -- 16ビット符号なし整数配列
%     int32           -- 32ビット符号付き整数配列
%     uint32          -- 32ビット符号なし整数配列
%     int64           -- 64ビット符号付き整数配列
%     uint64          -- 64ビット符号なし整数配列
%     integer         -- 上記 8 個の整数クラスいずれかの配列
%     numeric         -- 整数または浮動小数点配列
%     cell            -- セル配列
%     struct          -- 構造体配列
%     function_handle -- 関数ハンドル
%     <class_name>    -- カスタムMATLABオブジェクトクラスまたはJavaクラス
%
% 参考 ISNUMERIC, ISLOGICAL, ISCHAR, ISCELL, ISSTRUCT, ISFLOAT,
%      ISINTEGER, ISOBJECT, ISJAVA, ISSPARSE, ISREAL, CLASS.

%   Copyright 1984-2004 The MathWorks, Inc. 
