% FNCMB   関数の算術
%
% FNCMB(function,operation) は、関数に操作を適用します。特に、
%   FNCMB(function,scalar)    関数にスカラをかけます。
%   FNCMB(function,vector)    ベクトルによって、関数の値を平行移動します。
%       (関数がスカラ値の場合、FNCMB(function,'+',scalar) を使用して、
%        スカラにより関数を平行移動します。)
%   FNCMB(function,matrix)    関数の係数に行列を適用します。
%   FNCMB(function,string)    m-ファイル、または、関数の係数に文字列に
%                             よって指定された関数を適用します。
%
% FNCMB(function,function) は、同じ型の2つの関数の和です。
% FNCMB(function,matrix,function) は、
%         FNCMB(fncmb(function,matrix),function) と同じです。
% FNCMB(function,matrix,function,matrix) は、
%         FNCMB(fncmb(function,matrix),fncmb(function,matrix)) と同じです。
%                        
% FNCMB(function,op,function) は、2つの関数(場合によっては異なる型)の和
%                      (op は '+')、差(op は '-')、または点に関する積
%                      (op は '*')です。特に、加算/減算の場合、2番目の
%                      関数は、1番目の関数の目安となるただ1点(すなわち
%                      定数関数)であるかもしれません。
%
% 今のところ、すべての関数は、FNCMB(function,operation) の呼び出しを
% 除いて、1変数(UNIVARIATE)でなければなりません。
%
% 例題:
%
%      fncmb( sp1, '+', sp2 );
%
% は、SP1 にある関数と SP2 にある関数の(点に関する)和を出力し、
%
%      fncmb( spmak( augknt(4:9,4), eye(8) ), [1:8] )
%
% は、節点列 AUGKNT(4:9,4) に対して、8つのキュービックB-スプライン B_j 
% に対する sum_{j=1:8} j*B_j を作成するための複雑な方法です。
%
% SP が、B-型のスプラインを含む場合、
%
%      spa = fncmb( sp, 'abs' );
%
% は、その係数をすべて絶対値に変更します。
% 
% FN が、3つのベクトル値関数(すなわち、R^3 への写像)の場合、
%
%      fncmb( fn, [1 0 0; 0 0 1] )
%
% は、(x,z) 平面への射影を出力します。
%
%      fncmb( fncmb (fn, [1 0 0; 0 0 -1; 0 1 0] ), [1;2;3] )
%
% は、FN にある関数のイメージをx軸の周りに90度回転し、そのつぎにベクトル 
% (1,2,3) によって平行移動します。


%   Copyright 1987-2003 C. de Boor and The MathWorks, Inc.
