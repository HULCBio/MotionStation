%DOCROOT MATLAB Help のルートディレクトリの取得および設定ユーティリティ
% DOCROOT は、カレントの docroot を出力します。
% DOCROOT(NEW_DOCROOT) は、docroot に新規の docroot を設定します。
%
% documentation root ディレクトリは、デフォルトで MATLABROOT/help に設定
% されます。他の位置にあるドキュメントは、実行中のバージョンと互換ではないため、

% この値を変更する必要はありません。しかし、他の場所からのドキュメントを
% 希望する場合、値を他のディレクトリに設定するために、この関数をコールする
% ことにより、docroot を変更できます。 この値は、セッション間で保存されません。
% MATLAB の実行毎に、この値を設定するためには、docroot へのコールが、
% startup.m に挿入されます。

%   Copyright 1984-2002 The MathWorks, Inc.
