% MATLABPATH   サーチパス
% 
% MATLABPATH は、サーチパスの取得や設定を行う組み込み関数です。パスの
% 要素を有効にするのとパスを変更するのが簡単なので、MATLABPATH の代わり
% にM-ファイル PATH を使用してください。パスは、PATHSEP のキャラクタで
% 区切られたディレクトリリストです。このリストは、関数や他のファイルを
% 探すときにMATLABが検索するディレクトリの集合です。
%
% MATLABPATH自身では、MATLABのカレントのサーチパスを表示します。
% P = MATLABPATH は、パスを含む文字列をPに出力します。
% MATLABPATH(P) は、パスをPに変更します。 
%
% 参考：PATH, PATHSEP.



%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.10.4.1 $  $Date: 2004/04/28 01:53:20 $
%   Built-in function.
