%ACCUMARRAY アキュミュレーションにより配列を構成します
%
% A = ACCUMARRAY(IND,VAL) は、IND の対応する行をインデックスとして
% 使用して、VALの要素から配列を作成します。IND がNDIM 列をもつ行列
% の場合、A は、NDIM 次元とサイズ MAX(IND) をもつ配列になります。
% IND が列ベクトルの場合、A は、列ベクトルになります。VAL がスパース
% の場合、A はスパースで、2D 行列に限られます。VAL が fullの場合、
% A も fullです。VAL は、INDの行数と同じ長さのベクトルである必要が
% あります。VAL がスカラーの場合、IND のすべてのインデックスに対して、
% 同じ値が使用されます。IND の繰り返しインデックスでのVALの要素は、
% アキュミュレートされ、加算されます。指定されていないインデックス
% での値は、0です。
%    
% A = ACCUMARRAY(IND,VAL,SZ) は、サイズ SZ の配列を作成します。
% SZ は、IND と同じ数の列をもつ行ベクトルであり、SZ の要素は、
% MAX(IND)の対応する要素よりも大きくなければなりません。
%
% A = ACCUMARRAY(IND,VAL,SZ,FUN) は、関数 FUN を使用して、繰り返し
% インデックスでの値を蓄積します。FUN は、関数ハンドルにより指定
% されます。FUN は、ベクトルを受け取り、スカラーを返す必要があり
% ます。たとえば、デフォルトは FUN=@SUM です。ここで、S=SUM(X) は、
% べクトル入力 X を受け取り、スカラー出力 S を返します。
%
% A = ACCUMARRAY(IND,VAL,SZ,FUN,FILLVALUE) は、値 FILLVALUE を
% 使用して、指定していないインデックスでの値を記述します。
%    
% 例題: 5x5 行列の作成:
%    ind = [1 2 5 5;1 2 5 5]';
%    dat = [10.1 10.2 10.3 10.4]';
%    A  = accumarray(ind, dat);
%    A1 = accumarray(ind, dat, [5,5], @prod);
%    A2 = accumarray(ind, dat, [5,5], @max, -inf);
%            
% 参考 FULL, SPARSE, SUM.

%   Copyright 1984-2003 The MathWorks, Inc.
