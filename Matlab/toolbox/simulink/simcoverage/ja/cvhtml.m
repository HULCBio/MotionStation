% CVHTML   cvdata オブジェクトの HTML レポートの作成
%
%
% CVHTML(FILE,DATA) は、coverage 結果の HTML レポートを cvdata オブジェクト
% DATA に出力します。レポートは、FILE に書き込まれます。
%
% CVHTML(FILE,DATA1,DATA2,...) は、いくつかのデータオブジェクトの組み合わせた
% レポートを作成します。各オブジェクトからの結果は、別々な列に表示されます。
% 各データオブジェクトは、同じサブシステムに対応していなければなりません。 そ
% の他の場合は、エラーを生じます。
%
% CVHTML(FILE,DATA1,DATA2,...,OPTIONS) は、符号化した文字列を用いてレポート生
% 成オプションを指定します。オプションの文字列は、形式 -XXX=1または、-XXX=0
% のスペースで区切られたリストになります。オプションの記述は、
% cvhtml help options のコマンドを使って見ることができます。
%
% CVHTML(FILE,DATA1,DATA2,...,OPTIONS,DETAIL)  は、DETAIL に設定した整数、
% 0から3の数字に従った詳細さをもつレポートを作成します。数字が大きいほど詳細
% であることを示します。デフォルト値は2です。
%
% 参考 : CVDATA, CVREPORT.


% Copyright 1990-2003 The MathWorks, Inc.
