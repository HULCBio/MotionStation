% GENFIS1 グリッドパーティションを使ったANFIS訓練のための初期菅野タイプ
%         のFISを作成します。
%
% FIS = GENFIS1(DATA)は、データのグリッドパーティション（クラスタリングなし）
% を使った単出力の菅野タイプファジー推論システム(FIS)を作成します。FISは
% ANFIS訓練の初期条件設定に利用されます。DATAはN+1列の行列で、最初のN列は
% 各FIS入力のデータ、最後の行は出力データを含みます。デフォルトで、
% GENFIS1は2つの'gbellmf'タイプのメンバシップ関数を各入力に利用します。
% GENFIS1で生成される各ルールは一出力メンバシップ関数を持ちます。
% デフォルトは'linear'タイプです。
%
% FIS = GENFIS1(DATA, NUMMFS, INPUTMF, OUTPUTMF) は厳密に指定します。
%
% NUMMFS    :各入力に関連するメンバシップ関数の数を指定したベクトルです。
%            各入力に対して同数のメンバシップ関数を与えるときは、numMFs 
%            に1つの数字を与えるのみで構いません。
% INPUTMF  :各入力に関するメンバシップ関数タイプを、行列の各行で指定し
%            た文字配列です。各入力に同じメンバシップ関数タイプを用いる
%            ときには、1行の文字列で構いません。この関数(genfis1)は、パ
%            ラメータ numMFs と inmftype を、入力メンバーシップ関数パラ
%            メータを生成する関数 genparam に直接渡します。
% OUTPUTMF :出力に関するメンバシップ関数タイプを指定する文字列です。菅
%            野タイプのシステムなので、1出力となります。出力メンバシップ
%            関数タイプは、linear、または、constant でなければなりません。
%
% 例題
%    data = [rand(10,1) 10*rand(10,1)-5 rand(10,1)];
%    numMFs = [3 7];
%    mfType = str2mat('pimf','trimf');
%    fismat = genfis1(data,numMFs,mfType);
%    [x,mf] = plotmf(fismat,'input',1);
%    subplot(2,1,1),plot(x,mf);
%    xlabel('input 1 (pimf)');
%    [x,mf] = plotmf(fismat,'input',2);
%    subplot(2,1,2),plot(x,mf);
%    xlabel('input 2 (trimf)');
%
% 参考    GENFIS2 ANFIS



%   Copyright 1994-2002 The MathWorks, Inc. 
