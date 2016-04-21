%DOCOPT Web ブラウザのデフォルト
% DOCOPT は、ユーザ、または、システム管理者が、使用する Web ブラウザを
% 設定するためにエディットできる M-ファイルです。この中には、Java ベース
% の Desktop GUI をサポートしていない(このようなプラットフォームに関する
% 情報は、リリースノートを参照してください)プラットフォームに対して
% MATLAB オンラインドキュメントの位置も設定することができます。通常、
% Desktop のヘルプブラウザは、HTML の内容を表示する関数 DOC や Web で
% 使用できます。そして、ドキュメントの位置は、Desktop の環境設定ウィンドウ
% 内に設定することができます。DOCOPT は、関数WEB が、-BROWSER オプション
% 付きで、使用された場合、ウェブブラウザを設定するために使うことができ
% ます。DOCOPT は、UNIX プラットフォームのみで使用できます。
%
% [DOCCMD,OPTIONS,DOCPATH] = DOCOPT は、3つの文字列 DOCCMD, OPTIONS, 
% DOCPATH を出力します。DOCCMD は、(Desktop のヘルプブラウザの代わりに)
% Web ブラウザを起動するために、DOC または WEB が使用するコマンドを含む
% 文字列です。
%
%	   Unix:      netscape
%	   Mac:       -na-	
%	   Windows:   -na-
%
% OPTIONS は、DOC コマンドが呼び出されるときに、DOCCMD の呼び出しに付随
% する追加のコンフィギュレーションオプションを含む文字列です。デフォルトは、
% 以下の通りです。
%
%	   Unix:      ''
%	   Mac:       -na-
%	   Windows:   -na-
%
% DOCPATH は、MATLAB オンラインドキュメントファイルへのパスを含む文字列です。
% DOCPATH が空の場合、関数 DOC は、デフォルトの位置のヘルプファイルを検索
% します。
%
% Unix 上でのコンフィギュレーション:
% ----------------------------------
% 1. グローバルなデフォルトに対する、このファイルの編集と置き換え
%         $MATLAB/toolbox/local/docopt.m
%
% 2.ユーザ設定の優先順位に対して、1の中で設定した値の書き換え
% 
%   $MATLAB/toolbox/local/docopt.m
% 
% を
% 
%   $HOME/matlab/docopt.m
% 
% にコピーし、その位置で、ユーザによる変更を行います。MATLABの中で、
% ディレクトリを作成し、それをコピーするUnixコマンドは、つぎのものです。
%
%         !mkdir $HOME/matlab
%         !cp $MATLAB/toolbox/local/docopt.m $HOME/matlab
%
% カレントMATLABセッションで、効率化のため変更を行うには、$HOME/matlab が、
% ユーザのMATLABPATH上に存在することを確認してください。このディレクトリ
% が、MATLABのスタートアップ以前に存在すれば、問題になるかもしれません。
% また、ユーザのパス上に存在しない場合は、つぎのようにタイプして、
%
%               addpath([getenv('HOME') '/matlab'])
%
% ユーザの MATLABPATH の最初に、それを加えてください。
%
% 参考 DOC.

%   Copyright 1984-2004 The MathWorks, Inc.
