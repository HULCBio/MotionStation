% MATLAB Compiler
% Version 4.0 (R14) 05-May-2004
%
% コンパイラ
% mcc           - MATLAB Compiler ドライバ
% mccexec       - 実際の M コードから C Compiler mex ファイル
% mbuild        - MEX、C-ファイル、スタンドアロンアプリケーションを構築
% componentinfo - Builderコンポーネントに対する情報の種類と登録
%
% 型宣言
% mbint         - 整数として宣言
% mbreal        - 実数として宣言
% mbchar        - キャラクタとして宣言
% mbscalar      - スカラでなければなりません
% mbvector      - ベクトルとして宣言
% mbintscalar   - 整数スカラでなければなりません
% mbintvector   - 整数ベクトルとして宣言
% mbrealscalar  - 実数スカラでなければなりません
% mbrealvector  - 実数ベクトルとして宣言
% mbcharvector  - キャラクタベクトルとして宣言(MATLAB 文字列)
% mbcharscalar  - キャラクタのスカラとして宣言
%
% 実数関数
% reallog       - 実数の対数
% realpow       - 実数のベキ乗
% realsqrt      - 実数の平方根
% 
% プラグマ
% function      - feval() から呼び出される関数を識別するために、スタンド
%                 アロンモードで利用
% mex           - そのM-ファイルが同一ディレクトリにあるmexファイルの
%                 ダミーで、無視されることを示します。
% external      - このファンクションはCのハンドコードにより実装されます。


%   Copyright 1984-2004 The MathWorks, Inc. 
% $Revision $  $Date: 2004/03/22 23:53:46 $