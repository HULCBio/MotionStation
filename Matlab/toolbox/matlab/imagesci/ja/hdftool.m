% HDFTOOL    HDFまたはHDF-EOSファイルからのブラウズとインポート
% 
% HDFTOOL は、HDFおよびHDF-EOSファイルの内容をブラウズし、データやデータの
% サブセットをインポートするグラフィカルユーザインタフェースです。  
%
% HDFTOOL は、open fileダイアログボックスを使ったツールを起動します。
% HDFまたはHDF-EOSファイルを選択してHDFTOOLを起動してください。
%
% HDFTOOL(FILENAME) は、HDFまたはHDF-EOSファイルFILENAMEを、HDFTOOL
% にオープンします。
%
% H = HDFTOOL(...)  は、ツールのハンドル番号 H を出力します。DISPOSE(H) と
% H.dispose は、両方共コマンドラインからツールを閉じます。
%
% MATLABセッション中には、HDFTOOLは1つだけ起動できます。HDFTOOL.では複
% 数ファイルをオープンすることができます。デフォルトでは、HDF-EOSファイルは
% HDF-EOSファイルとして見ることができます。HDF-EOSファイルは、"View"を変更
% することによって、HDFファイルとして見ることができます。 
%
% 例題
% ----
%   hdftool('example.hdf');
%
% 参考 ： HDFINFO, HDFREAD, HDF, UIIMPORT.


%   Copyright 1984-2002 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/28 01:57:01 $
