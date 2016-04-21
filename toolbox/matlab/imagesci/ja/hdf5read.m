%HDF5READ HDF5 ファイルからデータを読み込みます
%
% HDF5READ は、HDF5 ファイルのデータセットからデータを読み込みます。
% データセットの名前が既知の場合、HDF5READ は、ファイルのデータ検索
% をします。そうでない場合、ファイルの内容を記述する構造体を取得する
% ために、HDF5INFO を使用してください。HDF5INFO により出力される構造体
% のフィールドは、ファイルに含まれるデータセットを記述する構造体です。
% データセットを記述する構造体は、取り出され、HDF5READ に直接渡され
% ます。これらのオプションについて、以下に詳細を述べます。
%
% DATA = HDF5READ(FILENAME,DATASETNAME) は、変数 DATA に、DATASETNAME
% という名前のデータについて、ファイル FILENAME から、すべてのデータを
% 出力します。
%
% ATTR = HDF5READ(FILENAME,ATTRIBUTENAME) は、変数 ATTR に、
% ATTRIBUTENAME という名前の属性について、ファイル FILENAME から、すべて
% のデータを出力します。
%
% [DATA, ATTR] = HDF5READ(..., 'ReadAttributes', BOOL) は、データセット
% のデータ情報を、そのデータセットに含まれる関連する属性情報とともに
% 出力します。デフォルトでは、BOOL は、false です。
%
% DATA = HDF5READ(HINFO) は、変数 DATA に、HINFO により記述される特定の
% データセットについて、ファイルから、すべてのデータを出力します。
% HINFO は、HDFINFO の出力構造体から取り出される構造体です(例題参照)。
%   
% 例題:
%
%   % HDF5INFO 構造体にもとづくデータセットの読み込み
%   info = hdf5info('example.h5');
%   dset = hdf5read(info.GroupHierarchy.Groups(2).Datasets(1));
%
% 参考 HDF5INFO, HDF5WRITE, HDF5COPYRIGHT.TXT.

%   binky
%   Copyright 1984-2002 The MathWorks, Inc. 
