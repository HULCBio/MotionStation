% FRD   周波数応答データモデルへの変換または作成
%
%
% 周波数応答データ(FRD)モデルは、実験応答データを含む LTI システムの周波数応答
% をストアするのに有効です。
%
% 作成:
%   SYS = FRD(RESPONSE,FREQS) は、FREQS の周波数点での応答データ RESPONSEをもつ
%   FRDモデル SYS を作成します。出力引数 SYS はFRDモデルです。
%   詳細は以下の｢データフォーマット｣を参照してください。
%
%   SYS = FRD(RESPONSE,FREQS,TS) は、サンプル時間 TS (サンプル時間を指定しない
%   場合は、TS = -1 に設定してください)の離散時間FRDモデルを作成します。
%
%   SYS = FRD は、空のFRDモデルを作成します。
%
%   上記のすべての書式では、入力リストに続けて、つぎの組を設定できます。 
%     'PropertyName1', PropertyValue1, ... 
%   これらの組は、FRDモデルの様々なプロパティを設定します(詳細は、
%   LTIPROPSとタイプしてください)。
%   書式 SYS = FRD(RESPONSE,FREQS,REFSYS) は、定義済みのLTIモデル REFSYSから
%   すべてのLTIプロパティを継承する SYS を作成します。
%
% データフォーマット:
%   SISO モデルに対して、FREQS は実周波数ベクトルで、RESPONSE は応答データ
%   ベクトルです。 ここで、RESPONSE(i) は、FREQS(i) でのシステムの応答を
%   表現します。
%
%   NU 入力 NY 出力で、周波数点 NF の MIMOFRDモデルに対して、RESPONSE は、
%   NY*NU*NF 配列で、RESPONSE(i,j,k) は、周波数 FREQS(k) での入力 j から
%   出力iまでの周波数応答を指定します。
%
%   デフォルトでは、FREQSの周波数単位は 'rad/s' です。
%   'Units' プロパティを変更することで、単位を 'Hz' に変更することができます。
%   このプロパティを変更しても周波数の数値が変更されないことに注意してください。
%   CHGUNITS(SYS,UNITS) を用いて、FRD モデルの周波数単位を変更すると、必要な
%   変換が実行されます。
%
% FRDモデルの配列:
%   上記の RESPONSE に対して、ND 配列を利用することで、FRDモデルの配列を作成す
%   ることができます。たとえば、RESPONSE が、[NY NU NF 3 4] のサイズの配列のとき、
%     SYS = FRD(RESPONSE,FREQS) 
%   は、3行4列のFRDモデルの配列を作成します。 ここで、
%     SYS(:,:,k,m) = FRD(RESPONSE(:,:,:,k,m),FREQS),  k = 1:3,  m = 1:4
%   です。
%   各々のFRDモデルは、NU 入力 NY 出力で、FREQS の各々の周波数点でのデータを
%   もちます。
%
% 変換:
%   SYS = FRD(SYS,FREQS,'Units',UNITS) は、任意のLTIモデル SYS を FRD モデル
%   表現に変換し、FREQS の各周波数でのシステムの応答を作成します。UNITS は、
%   FREQS での周波数単位で、'rad/s' または 'Hz' です。 最後の2つの引数が省略
%   された場合、デフォルトは 'rad/s' になります。結果は、FRDモデルです。
%
% 参考 : LTIMODELS, SET, GET, FRDATA, CHGUNITS, LTIPROPS, TF, ZPK, SS.


% Copyright 1986-2002 The MathWorks, Inc.
