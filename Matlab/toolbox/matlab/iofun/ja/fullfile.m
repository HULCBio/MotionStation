% FULLFILE   完全なファイル名を複数のファイルから作成
% 
% FULLFILE(D1,D2、... ,FILE) は、ディレクトリ D1、D2 等と指定したファイル名
% FILE から完全なファイル名を作成します。これは、ディレクトリの部分 D1、D2
% 等が、filesep で始まったり終了したりする場合に対して注意をする以外は、
% 概念的に
%
%    F = [D1 filesep D2 filesep ... filesep FILE] 
%
% と等価です。パス名をパスの部分から求めるためには、FILE = '' を指定して
% ください。
%
% 例題
% プラットフォーム固有のファイルのパスを作成するためには、
%        fullfile(matlabroot,'toolbox','matlab','general','Contents.m')
%
% プラットフォーム固有のディレクトリのパスを作成するためには
%        addpath(fullfile(matlabroot,'toolbox','matlab',''))
%
% 参考：FILESEP, PATHSEP, FILEPARTS.


%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.9.4.1 $ $Date: 2004/04/28 01:58:15 $
