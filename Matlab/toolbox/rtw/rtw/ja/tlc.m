% TLC   Target Language Compiler
%
%     tlc [options] main-file
%
% Target Language Compilerは、model.rtwファイルからCコードを生成するため
% に Real Time Workshopによって用いられます。
%
% RTWのbuildスクリプトは、Target language compilerを自動的に呼び出して、
% この変換を行います。ユーザは、一般にこれを直接呼び出す必要はありません。
% 詳細は、Target Language Compilerのドキュメントを参照してください。
%
%
% オプション:
%
%   -r <name>         用いられるRTWファイルが<name>であることを指定。
%
%   -v[<number>]      レベルが省略された場合、verbose level (1)を指定。
%
%   -I<path>          ローカルインクルードファイルへのパスを指定。TLCは、
%                     指定された順にこのパスをサーチします。
%
%   -m[<number>|a]    .tlcファイルの変換を終了する前に、TLCがレポートす
%                     るエラーの最大数(デフォルトは5)を指定。
%
%   -O<path>          出力ファイルを置くパスを指定。デフォルトでは、全て
%                     のTLC 出力は、このディレクトリに作成されます。
%
%   -d[g|n|o]         TLCのデバッグモードを呼び出します。このモードでは、
%                     TLCはコンパイル中にヒットしたラインとヒットしない
%                     ラインを示すログファイルを生成します。
%
%   -a<ident>=<expression>
%                     このオプションを使って、TLCプログラムの挙動を変更
%                     するために用いるパラメータを指定します。このオプシ
%                     ョンは、パラメータのインラインやファイルサイズの制
%                     限等を設定するためにRTWによって用いられます。
%
% 例題
% mymodel.rtwをロードし、verboseモードで、基本的なリアルタイムTLCプログ
% ラムを実行します。
%
%	tlc -r mymodel.rtw -v grt.tlc
%
% 参考： RTWGEN, RTW, MAKE_RTW, RTW_C, TLC_C, SIMULINK

%	Copyright 1994-2001 The MathWorks, Inc.
