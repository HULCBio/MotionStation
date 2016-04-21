% RTW_C   RTW Cコードイメージの構築に用いるmakefileを作成
%
% RTW_Cは、イメージを作成するために用いるmakefileをtemplateMakefileから
% 作成します。
%
% この関数は、make_rtwで呼び出すように設計されています。
% 全ての引数(modelName,rtwroot,templateMakefile,buildOpts,buildArgs)は、
% 前もって設定されていると仮定します。
%
%       buildOptsは、以下のものを含む構造体です:
%          buildOpts.sysTargetFile
%          buildOpts.noninlinedSFcns
%          buildOpts.solver
%          buildOpts.numst
%          buildOpts.tid01eq
%          buildOpts.ncstates
%          buildOpts.mem_alloc
%          buildOpts.modules
%          buildOpts.RTWVerbose
%          buildOpts.codeFormat
%          buildOpts.compilerEnvVal 
%                 '' または、コンパイラに対する環境変数の位置。これは、
%                    どのテンプレートmakefileを利用するか決定するために、
%                    mex preferencesファイルを用いる場合、PC上では非NULL
%                    です。

%       Copyright 1994-2001 The MathWorks, Inc.
