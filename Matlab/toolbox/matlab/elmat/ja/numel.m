% NUMEL   配列または、サブスクリプト化された配列表現の中の要素数
%
% N = NUMEL(A) は、配列 A の中の要素数N を出力します。
%
% N = NUMEL(A, VARARGIN) は、A(index1, index2, ..., indexN) の中のサブス
% クリプト化された要素数をN に出力します。ここで、VARARGIN はセル配列
% 要素、index1, index2, ... indexN です。
%
% 組み込み関数 NUMEL は、カンマで分離された表現、たとえば、A{index1, 
% index2, ..., indexN} またはA.fieldname で作成された場合は、MATLAB 
% によりインプリシットにコールされます。 
%
% 多重定義した関数 SUBREF と SUBSASGN に関して、NUMEL の意味を記述するこ
% とは重要です。ここで、NUMEL は、SUBSREF から戻される期待される出力数
% (NARGOUT)を計算するために使用します。多重定義関数 SUBSASGN に対して、
% NUMEL はSUBSASGN を使って割り当てられる期待される入力数(NARGIN)を計
% 算するために使います。多重定義関数 SUBSASGN に対する NARGIN 値は、
% NUMEL により戻される値、スクリプトの構造体配列に割り当てられる変数を
% 意味します。
%
% 組み込み関数 NUMEL により戻される N の値は、そのオブジェクトに対するク
% ラス設計と一致することを保証することは、重要なことです。組み込み関数 
% NUMEL により戻される N の値が、多重定義関数 SUBSREF に対してNARGOUT 、
% 多重定義関数 SUBSASGN に対して NARGIN のどちらかの値と異なっている場合
% NUMEL は、クラス SUBSREF や SUBSASGN 関数と一致する N の値を戻すために
% NUMEL を多重定義する必要があります。そうしないと、MATLAB は、多重定義関
% 数 SUBSREF と SUBSASGN をコールするときに、エラーを発生させます。
%
% 参考：SIZE, PROD, SUBSREF, SUBSASGN, NARGIN, NARGOUT.


%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.2.4.1 $ $Date: 2004/04/28 01:51:36 $
%   Built-in function.
