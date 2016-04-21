% PERL   適切なオペレーションシステムを用いた perl スクリプトのコール
%
% PERL(PERLFILE) は、適切な perl の実行形式を使って、ファイル PERLFILE 
% によって指定された perl スクリプトをコールします。
%
% PERL(PERLFILE,ARG1,ARG2,...) は、perl のスクリプトファイル PERLFILE
% に ARG1,ARG2,... の引数を渡し、適切な perl の実行形式を使ってコール
% します。
%
% RESULT=PERL(...) は、perl をコールした結果を出力します。perl の exit 
% status がゼロでない場合、エラーが出力されます。
%
% [RESULT,STATUS] = PERL(...) は、perl スクリプトのコールの結果を出力し、
% その exit status を変数 STATUS に保存もします。
%
% 実行可能な Perl が利用可能でない場合、以下からダウンロードできます。
%     http://www.cpan.org
%
% 参考:  SYSTEM と PUNCT に含まれる ! (感嘆符) 



%   Copyright 1990-2002 The MathWorks, Inc.
