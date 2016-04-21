%HDF5WRITE  Hierarchical Data Format version 5 ファイルの書き込み
%
% HDF5WRITE(FILENAME, LOCATION, DATASET) は、DATASET のデータを 
% FILENAME という名前の HDF5 ファイルに追加します。LOCATION は、
% ファイルの DATASET を書き込む場所を定義し、Unix スタイルのパス
% に似ています。DATASET のデータは、下記の規則を使用して、HDF5 
% データタイプにマッピングされます。
%
% HDF5WRITE(FILENAME, DETAILS, DATASET) は、DETAILS 構造体の値を
% 使用して、FILENAME に DATASET を追加します。この構造体は、データ
% セットに対して、つぎのフィールドを含むことができます。
%
%      Location     ファイル内のデータセットの位置 (文字配列)。
%
%      Name         データセットに付ける名前 (文字配列)。
%
% HDF5WRITE(FILENAME, DETAILS, ATTRIBUTE) は、DETAILS 構造体の値を
% 使用して、FILENAME に、メタデータ ATTRIBUTE を追加します。
%
% 属性に対して、つぎのフィールドが必要になります。
%
%      AttachedTo   この属性が修正する、オブジェクトの位置。
%
%      AttachType   この属性が修正する、オブジェクトの種類を同定する
%                   文字列。とり得る値は、'group' と'dataset'です。
%
%      Name         データセットに付ける名前 (文字配列)。
%
% HDF5WRITE(FILENAME, DETAILS1, DATASET1, DETAILS2, ATTRIBUTE1, ...)
% は、FILENAME に 1つの操作で、複数の、データセット および/または 
% 属性を書き込む方法を提供します。各データセットと属性は、DETAILS 
% 構造体をもつ必要があります。
%
% HDF5WRITE(FILENAME, ... , 'WriteMode', MODE, ...) は、既存のファイ
% ルへの書き込みを、上書き(デフォルト) にするか、あるいは、既存の
% ファイルへのデータセットと属性の追加にするかどうかを指定します。
% MODE がとり得る値は、'overwrite' と 'append' です。
%
%
% データ変換規則:
%
%   (1) データが数値の場合、HDF5 データセットは、適当なHDF5 のデータ
%       タイプを含み、データスペースのサイズは、配列と同じサイズです。
% 
%   (2) データが文字列の場合、HDF5 ファイルは、1要素のデータセット
%       を含みます。その要素は、ヌルで終わる文字列です。
% 
%   (3) データが文字列のセル配列の場合、HDF5 データセット または、
%       属性は、HDF5 文字列データタイプをもちます。データスペースは、
%       セル配列と同じサイズをもちます。文字列の要素は、ヌルで終わ
%       りますが、割り当てはすべて、同じ最大の長さをもちます。
% 
%   (4) データがセル配列で、セルのすべてが、数値データのみ含む場合、
%       HDF5 データタイプは、配列です。配列の要素は、すべて数値で、
%       同じサイズとタイプをもつ必要があります。配列のデータスペース
%       は、セル配列と同じ次元をもちます。要素のデータタイプは、最初の
%　　 　要素と同じ次元をもちます。
% 
%   (5) データが構造体配列の場合、HDF5 データタイプは、混合のタイプ
%       になります。構造体の個々のフィールドは、 データタイプに対し、
%　 　　同じデータ変換を使用します(たとえば、文字列、または、配列に
%　   　関連するセル、など)。
% 
%   (6) データがHDF5 オブジェクトにより構成される場合、HDF5 データ
%　　 　タイプがオブジェクトのタイプに対応します。
%       - H5ENUM オブジェクトに対し、データスペースは、オブジェクトの
%　　 　　Data フィールドと同じ次元をもちます。
%       - 他のすべてのオブジェクトに対し、データスペースは、関数に
%         渡される HDF5 オブジェクトの配列と同じ次元をもちます。
%
%
% 例題:
%
% % (A) ルートグループに 5×5 UINT8 値データセットを書き込む
%   hdf5write('myfile.h5', '/dataset1', uint8(magic(5)))
%
% % (B) サブグループに 2×2 文字列データセットを書き込む
%   dataset = {'north', 'south'; 'east', 'west'};
%   hdf5write('myfile2.h5', '/group1/dataset1.1', dataset);
%
% % (C) 既存のグループにデータセットと属性を書き込む
%   dset = single(rand(10,10));
%   dset_details.Location = '/group1/dataset1.2';
%   dset_details.Name = 'Random';
%
%   attr = 'Some random data';
%   attr_details.Name = 'Description';
%   attr_details.AttachedTo = '/group1/dataset1.2';
%   attr_details.AttachType = 'dataset';
%    
%   hdf5write('myfile2.h5', dset_details, dset, attr_details, attr, ...
%              'WriteMode', 'append');
%
% % (D) オブジェクトを使用してデータセットを書き込む
%   dset = hdf5.h5array(magic(5));
%   hdf5write('myfile3.h5', '/g1/objects', dset);
%
%
% 参考 HDF5READ, HDF5INFO, HDF5COPYRIGHT.TXT.


% Process input arguments.

% Verify the data.






% Call MEX implementation.
