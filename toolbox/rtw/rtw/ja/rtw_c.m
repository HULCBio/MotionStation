% RTW_C   RTW C�R�[�h�C���[�W�̍\�z�ɗp����makefile���쐬
%
% RTW_C�́A�C���[�W���쐬���邽�߂ɗp����makefile��templateMakefile����
% �쐬���܂��B
%
% ���̊֐��́Amake_rtw�ŌĂяo���悤�ɐ݌v����Ă��܂��B
% �S�Ă̈���(modelName,rtwroot,templateMakefile,buildOpts,buildArgs)�́A
% �O�����Đݒ肳��Ă���Ɖ��肵�܂��B
%
%       buildOpts�́A�ȉ��̂��̂��܂ލ\���̂ł�:
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
%                 '' �܂��́A�R���p�C���ɑ΂�����ϐ��̈ʒu�B����́A
%                    �ǂ̃e���v���[�gmakefile�𗘗p���邩���肷�邽�߂ɁA
%                    mex preferences�t�@�C����p����ꍇ�APC��ł͔�NULL
%                    �ł��B

%       Copyright 1994-2001 The MathWorks, Inc.
