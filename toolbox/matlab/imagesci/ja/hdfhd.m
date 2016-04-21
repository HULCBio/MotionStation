% HDFHD   HDF HDインタフェースのMATLABゲートウェイ
% 
% HDFHDは、HDF HDインタフェースのゲートウェイです。この関数を使うためには、
% HDF version 4.1r3のUser's GuideとReference Manual に含まれている、Vdata
% インタフェースについての情報を知っていなければなりません。このドキュメ
% ントは、National Center for Supercomputing Applications (NCSA、
% <http://hdf.ncsa.uiuc.edu>)から得ることができます。
%
% HDFHDに対する一般的なシンタックスは、HDFHD(funcstr,param1,param2,...)
% です。HDFライブラリ内のV関数と、funcstr に対する有効な値は、1対1で対応
% します。
%
% シンタックスの使い方
% --------------------
% ステータス、または、識別子の出力が-1のとき、操作が失敗したことを
% 示します。
%
%   tag_name = hdfhd('gettagsname',tag)
%   指定したタグ名を取得します。
%
% 参考：HDF.


%   Copyright 1984-2002 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/28 01:56:52 $
