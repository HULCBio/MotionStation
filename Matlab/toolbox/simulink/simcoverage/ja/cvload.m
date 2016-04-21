% CVLOAD   ファイルから coverage テストや結果をロード
%
%
% [TESTS, DATA] = CVLOAD(FILENAME) は、テキストファイル FILENAME.CVT とバイ
% ナリファイル FILENAME.CVB にストアされているテストとデータをロードします。
% ロードが成功すると、TESTS の中に、cvtest オブジェクトのセル配列を出力します。
% DATA は、うまくロードされた cvdata オブジェクトのセル配列です。DATA は、
% TESTS と同じサイズをもちますが、特定のテストが結果をもたない場合、空の要素
%
% [TESTS, DATA] = CVLOAD(FILENAME, RESTORETOTAL) は、RESTORETOTAL が1の場合、
% 以前の実行からの累積結果を復元します。RESTORETOTAL が0の場合、モデルの累積
% 結果はクリアされます。
%
% 特別な考え方：
%
% 1. 同じ名前をもつモデルが、coverage データベースの中に存在する場合、重複する
% ことを避けるため、存在しているモデルを調べ、整合性をもつ結果のみがファイル
% からロードされます。
%
% 2. ファイルから参照された Simulink モデルが開かれてはいるが coverageデー
% タベース内に存在していない場合、coverage ツールは、存在しているモデルとのリン
% クを解きます。
%
% 3. 同じモデルを参照しているいくつかのファイルをロードするとき、初期のファイ
% ルと整合性のある結果のみがロードされます。
%
% 参考 : CVDATA, CVTEST, CVSAVE.


% Copyright 1990-2002 The MathWorks, Inc.
