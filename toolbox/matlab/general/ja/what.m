% WHAT   ディレクトリ内のMATLAB固有のファイルのリスト
% 
% WHAT 自身では、カレントの作業ディレクトリ内のMATLAB固有のファイルを
% リストします。ほとんどのデータファイルや他のMATLABファイル以外のファ
% イルはリストされません。DIR を使って、すべてのリストを得ることもでき
% ます。
%
% WHAT DIRNAME は、MATLABPATH上のディレクトリ dirname 内のファイルを
% リストします。ディレクトリのフルパス名を指定する必要はありません。
% MATLABPATHの相対部分パス名が代わりに指定できます(PARTIALPATHを参照)。
% たとえば、"what general" と "what matlab/general" は共に、ディレクトリ
% toolbox/matlab/genera 内のM-ファイルをリストします。
%
% W = WHAT('directory') は、つぎのフィールドをもつ構造体配列に WHAT の
% 結果を出力します。
% 
%     path    -- ディレクトリのパス
%     m       -- M-ファイル名を要素とするセル配列
%     mat     -- MAT-ファイル名を要素とするセル配列
%     mex     -- MEX-ファイル名を要素とするセル配列
%     mdl     -- MDL-ファイル名を要素とするセル配列
%     p       -- P-ファイル名を要素とするセル配列
%     classes -- クラス名を要素とするセル配列
%
% 参考：DIR, WHO, WHICH, LOOKFOR.


%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.10.4.1 $  $Date: 2004/04/28 01:53:44 $
%   Built-in function.
