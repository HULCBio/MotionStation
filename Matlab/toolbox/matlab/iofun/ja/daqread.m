% DAQREAD   Data Acquisition Toolbox の (.daq) データファイルの読み込み
%
% DATA = DAQREAD('FILENAME') は、FILENAME のデータ収集ファイルを読み込
% み、DATA に M×N のデータ行列として出力します。ここで、M はサンプル
% 数が指定され、N はチャンネル数が指定されています。複数のトリガから成る
% データの場合、各トリガからのデータは、NaN によって分離されています。
%
% [DATA, TIME] = DAQREAD('FILENAME') は、FILENAME のデータ収集ファイル
% を読み込み、時間の値を組として出力します。TIME は DATA と同じ長さで、
% 最初のトリガに関連する各データサンプルの相対的な時間を示すベクトルです。
%
% [DATA, TIME, ABSTIME] = DAQREAD('FILENAME') は、最初のトリガの絶対時間 
% ABSTIME を出力します。ABSTIME は、CLOCK ベクトルとして返されます。
%
% [DATA, TIME, ABSTIME, EVENTS] = DAQREAD('FILENAME') は、イベントの
% ログを含む構造体 EVENTS を出力します。
%
% [DATA,...] = DAQREAD('FILENAME', 'P1', V1, 'P2', V2,...) は、ファイル 
% FILENAME の DATA 行列の形式と TIME 行列の形式から読み込まれるデータ量を
% 指定します。
%
% 有効なプロパティ名 (P1, P2,...) とプロパティ値 (V1, V2,...) は以下の
% とおりです。
%
%      Samples    -  [sample range]
%      Time       -  [time range in seconds]
%      Triggers   -  [trigger range]
%      Channels   -  [channel indices or cell array of ChannelNames]
%      DataFormat -  [ {double} | native ]
%      TimeFormat -  [ {vector} | matrix ]
%
% Samples、Time と Triggers プロパティは互いに排他的です。すなわち、
% Samples、Triggers または Time は一度に定義することができます。
%
% DataFormat と TimeFormat プロパティに対するデフォルト値は、{} で
% 囲まれたものです。
%
% DAQINFO = DAQREAD('FILENAME', 'info') は、FILENAME のデータ収集ファイル
% を読み込み、以下の情報を含む構造体 DAQINFO を出力します。
%
%    DAQINFO.ObjInfo - ファイル FILENAME を作成するために使われる
%                      データ収集オブジェクトに対しての PV の組み合わ
%                      せが含まれる構造体です。
%                      注意: UserData プロパティ値は再格納されません。
%    DAQINFO.HwInfo  - ハードウェア情報が含まれる構造体
%
% DAQINFO 構造体は、以下の構文で得ることも可能です。
% [DATA, TIME, ABSTIME, EVENTS, DAQINFO] = DAQREAD('FILENAME')
%    
% Data Acquisition Toolbox のデータファイル(.daq)は、LogFileName 
% プロパティに対して指定された値と LoggingMode プロパティに 'Disk' 
% または 'Disk&Memory' が設定されることで作成されます。
%
% 例題:
%      data.daq ファイルからすべてのデータを読み込むためには、
%      以下のようにします。
%         [data, time] = daqread('data.daq');
%
%      data.daq ファイルから従来の形式で、2、4と7のチャンネル
%      インデックスの1000から2000までのサンプルのみを読み込む
%      ためには、以下のようにします。
%         data = daqread('data.daq', 'Samples', [1000 2000],...
%                                'Channels', [2 4 7], 'DataFormat', 'native');
%
%      data.daq ファイルからすべてのチャンネルで最初と2番目の
%      トリガを表すデータのみを読み込むためには、以下のように
%      します。
%         [data, time] = daqread('data.daq', 'Triggers', [1 2]);
%
%      data.daq ファイルからチャンネルのプロパティ値を得るためには、
%      以下のようにします。
%         daqinfo = daqread('data.daq', 'info');
%         chaninfo = daqinfo.ObjInfo.Channel;
%     
% 参考 : DAQHELP, GETDATA.


%    MP 6-12-98
%    Copyright 1998-2002 The MathWorks, Inc.
