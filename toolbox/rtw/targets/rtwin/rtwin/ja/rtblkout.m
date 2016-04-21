%RTBLKOUT   Simulinkリアルタイムブロック出力を実行
%
%   Real Time Windows Targetによって用いられます。これは、rtbin.m, rtbout.m, 
%   rtblkin.mと同様にダミーのS-ファンクションです。このS-ファンクションにより、
%   simulinkモデルはフレームベースの出力データ(例. buffered)を取り扱うことができ
%   ます。シミュレーション中に、データは変更されずに転送されます。
%   コード生成中に、I/OデバイスドライバはこのS-ファンクションを置き換えます。
%
%   この関数は、直接は呼び出されません。

% $Revision: 1.5 $ $Date: 2002/04/14 18:51:47 $
%    Copyright 1994-2002 The MathWorks, Inc.
