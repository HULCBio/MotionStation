% CVTEST   モデルテストの仕様
%
% CLASS_ID = CVTEST( ROOT ) は、ROOT を含む Simulink モデルに対して、
% テスト仕様を作成します。ROOT は、Simulink モデル名か、または、Simulink 
% モデルのハンドルです。ROOT は、モデル内のサブシステムの名前、または、
% ハンドルでも構いません。この場合、このサブシステムとその下位のものが、
% 解析用に利用されます。
%
% CLASS_ID = CVTEST( ROOT, LABEL) は、与えられたラベルをもつテストを作成
% します。ラベルは、結果がレポートされた場合に使用されるものです。
%
% CLASS_ID = CVTEST( ROOT, LABEL, SETUPCMD) は、解析するためのシミュレー
% ションを実行する前に、ベースの MATLAB ワークスペースで、実行するセット
% アップ用コマンドと共にテストを作成します。セットアップコマンドは、テス
% トの前に、ロードしたデータに有効なものです。
%
% 参考 : CVSIM, CVSAVE, CVLOAD.


% 	Bill Aldrich
%   Copyright 1990-2002 The MathWorks, Inc.
