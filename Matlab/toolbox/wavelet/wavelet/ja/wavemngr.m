% WAVEMNGR�@ �E�F�[�u���b�g�̊Ǘ��R�}���h
% WAVEMNGR �́A�c�[���{�b�N�X�̃E�F�[�u���b�g���쐬������A��������A��
% ��������A�ۑ�������A�ǂݍ��񂾂肷����̂ł��B
%
% WAVEMNGR('add',FN,FSN,WT,NUMS,FILE)�A�܂��́AWAVEMNGR('add',FN,FSN,WT,%   NUMS,FILE,B)�A�܂��� WAVEMNGR('add',FN,FSN,WT,{NUMS,TYPNUMS},FILE)�A% �܂��́AWAVEMNGR('add',FN,FSN,WT,{NUMS,TYPNUMS},FILE,B) �́A�V�����E�F% �[�u���b�g�t�@�~����ǉ����܂��B
%   FN    = �t�@�~���l�[�� (������)
%   FSN   = �t�@�~���̗��� (������)
%
%   WT �́A�E�F�[�u���b�g�̃^�C�v���`���܂��B
%   WT    = 1 �A�����E�F�[�u���b�g
%   WT    = 2 �A�o�����E�F�[�u���b�g
%   WT    = 3 �A�X�P�[�����O�֐��t���E�F�[�u���b�g
%   WT    = 4 �A�X�P�[�����O�֐��Ȃ��E�F�[�u���b�g
%   WT    = 5 �A�X�P�[�����O�֐��Ȃ����f�E�F�[�u���b�g
%
% �E�F�[�u���b�g���P��̏ꍇ�ANUMS  = '' �ł��B
%    ��: mexh, morl
% �E�F�[�u���b�g���E�F�[�u���b�g�t�@�~���ŗL���̎����ł���ꍇ�ANUMS ��
% �E�F�[�u���b�g�p�����[�^��\�킷���ڂɃu�����N�ŋ�؂�ꂽ���X�g�ɁA��% ����Ƃ��Ċ܂܂�܂��B 
%    ��: bior, NUMS = '1.1 1.3 ... 4.4 5.5 6.8'
% �E�F�[�u���b�g���E�F�[�u���b�g�t�@�~���Ŗ����̎����ł���ꍇ�ANUMS ��
% ���ʂȃV�[�P���X�ł��� ** ���I���ɂ���悤�ȃE�F�[�u���b�g�p�����[�^% ��\�킷���ڂ��u�����N�ŋ�؂�ꂽ���X�g�ɕ�����Ƃ��Ċ܂܂�܂��B
%    ��: db,    NUMS = '1 2 3 4 5 6 7 8 9 10 **'
%        shan,  NUMS = '1-1.5 1-1 1-0.5 1-0.1 2-3 **'
% ������2�̃P�[�X�̍Ō�ŁATYPNUMS �̓E�F�[�u���b�g�p�����[�^�̓���
% �`���ł���A'integer' �܂��� 'real' �܂��� 'string' (�f�t�H���g�� 'int%   eger') ���w�肵�܂��B
%    ��: db,    TYPNUMS = 'integer'
%        bior,  TYPNUMS = 'real'
%        shan,  TYPNUMS = 'string'
%
%   FILE  = MAT �t�@�C���A�܂��́AM �t�@�C���� (������) �ł��B
%
%   B = [lb ub] �^�C�v3�A4 �܂��́A5�̃E�F�[�u���b�g�ɑ΂��āA�����I�ȃT%   �|�[�g�̉����Ə���ł��B
%
% WAVEMNGR('del',N) �́A�E�F�[�u���b�g�t�@�~���̍폜���s���܂��BN �́A�t% �@�~���̗��́A�܂��́A�t�@�~���̒��̃E�F�[�u���b�g���ł��B
%
% WAVEMNGR('restore')�A�܂��́AWAVEMNGR('restore',IN2) �́Anargin = 1 ��% �ꍇ�A��O�� wavelets.asc �t�@�C�����ۑ�����A���̏ꍇ�A������ wavel%   ets.asc �t�@�C�����ۑ�����܂��B
%
% OUT1 = WAVEMNGR('read') �́A���ׂẴE�F�[�u���b�g�t�@�~���̏o�͂ł��B%
% OUT1 = WAVEMNGR('read',IN2) �́A���ׂẴE�F�[�u���b�g�̏o�͂ł��B
%
% OUT1 = WAVEMNGR('read_asc')�́Awavelets.asc ASCII�t�@�C����ǂݍ��݁A
% ���ׂẴE�F�[�u���b�g�����o�͂��܂��B



%   Copyright 1995-2002 The MathWorks, Inc.
