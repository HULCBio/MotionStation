% SPTOOL  信号処理ツール - グラフィカルユーザインタフェース
%
% SPTOOLにより、SPToolウィンドウが開き、信号、フィルタ、スペクトルを読み
% 込んだり、解析したり、取り扱うことができます。
% 
% コマンドラインを使って、SPToolから対象物の構造体を転送する方法。
% ---------------------------------------------------------------
% 以下のコマンドによって、現在開かれている SPTool から構造体配列をワーク
% スペースに書き込みます。
%
% s = sptool('Signals')は、すべての信号の構造体配列を出力します。
% f = sptool('Filters')は、すべてのフィルタの構造体配列を出力します。
% s = sptool('Spectra')は、すべてのスペクトルの構造体配列を出力します。
%
% [s,ind] = sptool(...)は、SPTool 内でカレントに選択した構造体(s)の要素
% を示すインデックスベクトル(ind)を出力します。
%
% s = sptool(...,0)は、現在選択しているオブジェクトのみを出力します。
%
% コマンドラインを使って構造体配列を作成したり、ロードする方法。
% --------------------------------------------------------------
% struc = sptool('create',PARAMLIST)は、ワークスペース内に"PARAMLIST"で
% 定義した、構造体配列 strucを作成します。
%
% sptool('load',struc)は、SPTool内に構造体配列 struc をロードします。ま
% た、必要な場合、SPToolを開きます。
%
% struc = sptool('load',PARAMLIST)は、SPTool内に "PARAMLIST" によって定
% 義された、構造体配列 struc をロードします。また、オプションの出力引数
% を指定すれば、構造体配列 strucがワークスペース内に定義されます。
% 
% %
% COMPONENT           PARAMLIST
% ~~~~~~~~~           ~~~~~~~~~
% SIGNALS:   COMPONENT_NAME,DATA,FS,LABEL
% FILTERS:   COMPONENT_NAME,NUM,DEN,FS,LABEL
% SPECTRA:   COMPONENT_NAME,DATA,F,LABEL
%
% パラメータの定義
% ~~~~~~~~~~~~~~~~~
% COMPONENT_NAME - 'Signal', 'Filter', 'Spectrum'のいずれか、COMPONENT_
% NAME を省略するとデフォルトで'Signal'になります。
%   DATA    - 信号やスペクトラムを倍精度で表すベクトルです。
%   NUM,DEN - 伝達関数表現で表されたフィルタの分子、分母の係数です。
%   FS      - サンプリング周波数です(オプション)。デフォルトは、"1"です。
%   F       - 周波数ベクトル　; スペクトル成分のみに適用できます。.
%   LABEL   - SPTool内で表示される要素の変数名を指定する文字列です
%             (オプション)。デフォルトで、'sig'、 'filt'、 'spec'のいず
%             れかが使われます。
%   Copyright 1988-2001 The MathWorks, Inc.
