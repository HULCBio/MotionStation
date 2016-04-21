TABLEINFO - モデルオブジェクトのデシジョンカバレージ情報


COVERAGE = TABLEINFO(DATA, BLOCK)は、cvdataカバレージオブジェクトDATA内のBLOCKに対するテーブルカバレージを求めます。
BLOCKは、Simulinkブロックまたはモデルの絶対パス、あるいはSimulinkブロックまたはモデルハンドルのいずれかです。
COVERAGEは、2要素ベクトルとして出力されます: [covered_intervals total_intervals].
BLOCKに関する情報はDATAの一部でない場合は、COVERAGEは空です。

COVERAGE = TABLEINFO(DATA, BLOCK, IGNORE_DECENDENTS)は、BLOCKに対するテーブルカバレージを求め、IGNORE_DECENDENTSが真の場合は下層オブジェクト内のカバレージを無視します。

[COVERAGE,EXECCOUNTS] = TABLEINFO(DATA, BLOCK)は、カバレージを求め、核内挿区間の実行カウントを含む配列を生成します。

[COVERAGE,EXECCOUNTS,BRKEQUALITY] = TABLEINFO(DATA, BLOCK) は、等価性を調べるブレークポイントの数BRKEQUALITYを出力します。
セル配列BRKEQUALITYは、各テーブルデシジョンに対する等価性の数のベクトルを含みます。
ｓ
Copyright 1990-2003 The MathWorks, Inc.

