% MULTIBANDWRITE   ファイルへのマルチバンドのデータの書き込み
%
% MULTIBANDWRITE は、バイナリファイルに3次元のデータセットを書き出します。
% すべてのデータは1つの関数の呼び出しで書き込まれるか、または 
% MULTIBANDWRITE はファイルに完全なデータセットの一部を書き込むために
% 繰り返しコールされます。
%
% 以下の2つの構文は、1つの関数の呼び出しでファイルにすべてのデータ
% セットを書き込むために MULTIBANDWRITE を使用する方法です。以下に
% 記述されるオプションのパラメータ/値の対はこれらの構文と共に使用する
% ことができます。
%
%   MULTIBANDWRITE(DATA,FILENAME,INTERLEAVE) は、バイナリファイル 
%   FILENAME に任意の数値または論理タイプの2次元または3次元配列として
%   DATA を書き込みます。バンドは INTERLEAVE で指定された書式で
%   ファイルに書かれています。DATA の3番目の次元の長さは、バンドの数と
%   等価です。デフォルトでは、データはMATLABに格納されたものと同じ精度
%   でファイルに書き込まれます(DATA のクラスと同じです)。INTERLEAVE は、
%   ファイルに書き込まれたバンドにインターリーブの手法を指定する文字列
%   です。有効な文字列は それぞれ band-interleaved-by-line、
%   band-interleaved-by-pixel、band-sequential を表す'bil'、'bip'、
%   'bsq'です。DATA が2次元の場合は、INTERLEAVE は何も行いません。
%   FILENAME が既に存在する場合、オプションの OFFSET パラメータが指定
%   されていなければ上書きされます。
%     
% すべてのデータセットは、下記の構文を使用して MULTIBANDWRITE への複数
% のコールが作成され、ファイルに細分化された形で書き込まれます。
%
%   MULTIBANDWRITE(DATA,FILENAME,INTERLEAVE,START,TOTALSIZE) は、バイナリ
%   ファイルに少しずつデータを書き込みます。DATA はすべてのデータセットの
%   サブセットです。MULTIBANDWRITE は、ファイルにすべてのデータを書き込む
%   ために複数回コールされます。すべてのファイルは、最初の関数の呼び出し中
%   に書き込まれ、サブセットの外側が最初の呼び出しで与えられた値で満たされ
%   ます。そしてそれに続く呼び出しは埋められた値のすべて、あるいは一部を
%   上書きします。パラメータ FILENAME、INTERLEAVE、OFFSET および TOTALSIZE 
%   は、ファイルの全体を書き込むまでは一定のままであるべきです。
%
%      START == [firstrow firstcolumn firstband] は、1×3です。ここで、
%      firstrow と firstcolumn はボックス内の左上のイメージのピクセル
%      位置から与え、firstband は書き込むための最初のバンドのインデックス
%      を与えます。DATA は、いくつかのバンドに対していくつかのデータを
%      含んでいます。DATA(I,J,K) は、(firstband + K - 1)番目のバンド内の
%      [firstrow + I - 1, firstcolumn + J - 1]のピクセルに対するデータを
%      含みます。
%
%      TOTALSIZE == [totalrows,totalcolumns,totalbands] は、ファイルに
%      含まれているすべてのデータセットの3次元サイズすべてを与えます。
%
% これらのオプションパラメータ/値の数と組み合わせは、上記構文のいくつかの
% 最後に加えられます。
%
% MULTIBANDWRITE(DATA,FILENAME,INTERLEAVE,...,PARAM,VALUE,...) 
%
%   パラメータ値の組:
%     
%   PRECISION は、ファイルに書き込む各要素の書式とサイズをコントロール
%   するための文字列です。PRECISION に対する有効な値のリストについては
%   FWRITE のヘルプを参照してください。デフォルトの精度は、データの
%   クラスです。
%
%   OFFSET は、最初のデータ要素の前にスキップするためのバイト数です。
%   ファイルが既に存在する場合、デフォルトでスペースを満たすために
%   ASCIIのヌル値が書き込まれます。データを書き込む前に、あるいは書き
%   込んだ後に、ファイルにヘッダを書き込むときにこのオプションは有効です。
%   データを書き込んだ後にヘッダを書き込むとき、ファイルは パーミッション
%   'r+' を使用して FOPEN で開くべきです。
%
%   MACHFMT は、ファイルに書き込まれたデータの書式をコントロールする
%   文字列です。FOPEN でドキュメント化されている MACHINEFORMAT に対する
%   すべての値は有効ですが、標準の値は、little endian に対して 'ieee-le'、
%   big endian に対して 'ieee-be' です。すべてのリストは FOPEN を参照
%   してください。デフォルトのマシンフォーマットは、ローカルのマシン
%   フォーマットです。
%     
%   FILLVALUE は、不足データに対して指定される値の数です。FILLVALUE は
%   すべての不足したデータに対してfill値を指定する単一の数か、または 
%   各バンドに対してfill値を指定するバンドの数の 1×number のベクトル
%   です。この値はデータが細分化して書き込まれるときに、スペースを
%   埋めるために使われます。
%
% 例題:
%
%   1.  すべてのデータは1つの関数呼び出しでファイルに書き込まれます。
%       バンドは interleaved by line です。
%        
%         multibandwrite(data,'data.img','bil');
%  
%   2.  MUTLIBANDWRITE は、ファイルに各バンドを書き込むためにループの
%       中で使われます。
%
%       for i=1:totalBands
%           multibandwrite(bandData,'data.img','bip',[1 1 i],...
%                          [totalColumns, totalRows, totalBands]);
%       end
%       
%   3.  各バンドのサブセットのみ MULTIBANDWRITE への各呼び出しとして
%       利用可能です。例えば、すべてのデータセットは1024×1024ピクセル
%       の3つのバンド(1024×1024×3の行列)をもつかもしれません。
%       128×128の塊のみMULTIBANDWRITE への各呼び出しとしてファイルに
%       書き込むことが可能です。
%
%      numBands = 3;
%      totalDataSize =  [1024 1024 numBands];
%      for i=1:numBands
%         for k=1:8
%             for j=1:8
%                upperLeft = [(k-1)*128 (j-1)*128 i];
%                multibandwrite(data,'banddata.img','bsq',...
%                               upperLeft,totalDataSize);
%             end
%          end
%       end
%
% 参考 : MULTIBANDREAD, FWRITE, FREAD 


%   Copyright 1984-2002 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/28 01:57:10 $
%   $Revision.1 $  $Date: 2004/04/28 01:57:10 $


