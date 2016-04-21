% HDFML   MATLAB-HDFゲートウェイユーティリティ
% 
% HDFMLは、MATLAB-HDFのゲートウェイ関数と共に機能するユーティリティ
% 関数を提供します。MATLAB-HDFのゲートウェイ関数を使うためには、HDF 
% version 4.1r3のUser's GuideとReference Manualに含まれている情報に
% ついて知っていなければなりません。このドキュメントは、National Center 
% for Supercomputing Applications (NCSA)、<http://hdf.ncsa.uiuc.edu>)
% から得ることができます。
%
% HDFMLの一般的なシンタックスは、HDFML(funcstr,param1,param2,...) です。
%
% MATLABとHDFのゲートウェイ関数は、たとえば、ユーザがコマンド
%
%   clear mex
%
% を実行したときに、HDFオブジェクトとファイルが、正常にクローズするよう
% に、HDFファイルとデータオブジェクトの識別子のリストをもっています。こ
% れらのリストは、識別子が作成されたり、消去されるときに、更新されます。
% HDFMLが提供するうちの2つの関数は、これらの識別子のリストの操作のための
% 関数です。
%
%   hdfml('closeall')
%    オープンしているすべての登録されたHDFファイルと、データオブジェクトの
%    識別子をクローズします。
%
%   hdfml('listinfo')
%    オープンしているすべての登録されたHDFファイルと、データオブジェクトの
%    識別子に関する情報を表示します。
%
%   tag = hdfml('tagnum',tagname)
%    与えられたタグ名に対応するタグ番号を出力します。
%
%   nbytes = hdfml('sizeof',data_type)
%   指定したデータタイプのサイズを、バイト単位で出力します。
%
%   hdfml('defaultchartype',char_type)
%   MATLAB文字列用の HDFデータタイプを定義します。char_type 用の正しい値
%   は、'char8'、または、'uchar8'のいずれかです。MATLAB-HDFゲートウェイ
%   関数が、メモリからクリアされるまで、変更は保持されます。MATLAB文字列は、
%   デフォルトでは、char8 にマッピングされます。 
%
% 参考：HDF, HDFAN, HDFDF24, HDFDFR8, HDFH, HDFHD, HDFHE,
%       HDFSD, HDFV, HDFVF, HDFVH, HDFVS.


%   Copyright 1984-2002 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/28 01:56:56 $
