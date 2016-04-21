% HDFHE   HDF HEインタフェースのMATLABゲートウェイ
% 
% HDFHEは、HDF HEインタフェースへのゲートウェイです。この関数を使うため
% には、HDF version 4.1r3のUser's GuideとReference Manualに含まれている、
% Vdataインタフェースについての情報を知っていなければなりません。このド
% キュメントは、National Center for Supercomputing Applications (NCSA、
% <http://hdf.ncsa.uiuc.edu>)から得ることができます。
%
% HDFHEに対する一般的なシンタックスは、HDFHE(funcstr,param1,param2,...)
% です。HDFライブラリ内のV関数と、funcstr に対する有効な値は、1対1で対応
% します。
%
% シンタックスの使い方
% --------------------
% ステータス、または、識別子の出力が-1のとき、操作が失敗したことを示しま
% す。
%
%   hdfhe('clear')
%   報告されたエラーに関するすべての情報を、エラースタックから消去します。
% 
%   hdfhe('print',level)
%   エラースタック内の情報を表示します。level が0の場合は、エラースタック全部
%   が表示されます。
%
%   error_text = hdfhe('string',error_code)
%   指定したエラーコードに対応するエラーメッセージを出力します。
%
%   error_code = hdfhe('value',stack_offset)
%   エラースタックの指定したレベルから、エラーコードを出力します。
%   stack_offsetが1のとき、最新のエラーコードを取得します。
%
% HDFライブラリ関数 HEpush と HEreport は、現在はこのゲートウェイではサ
% ポートされていません。
%
% 参考：HDF, HDFAN, HDFDF24, HDFDFR8, HDFH, HDFHD, 
%       HDFML, HDFSD, HDFV, HDFVF, HDFVH, HDFVS.


%   Copyright 1984-2002 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/28 01:56:53 $
