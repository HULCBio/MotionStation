% GENFIS1 �O���b�h�p�[�e�B�V�������g����ANFIS�P���̂��߂̏�������^�C�v
%         ��FIS���쐬���܂��B
%
% FIS = GENFIS1(DATA)�́A�f�[�^�̃O���b�h�p�[�e�B�V�����i�N���X�^�����O�Ȃ��j
% ���g�����P�o�͂̐���^�C�v�t�@�W�[���_�V�X�e��(FIS)���쐬���܂��BFIS��
% ANFIS�P���̏��������ݒ�ɗ��p����܂��BDATA��N+1��̍s��ŁA�ŏ���N���
% �eFIS���͂̃f�[�^�A�Ō�̍s�͏o�̓f�[�^���܂݂܂��B�f�t�H���g�ŁA
% GENFIS1��2��'gbellmf'�^�C�v�̃����o�V�b�v�֐����e���͂ɗ��p���܂��B
% GENFIS1�Ő��������e���[���͈�o�̓����o�V�b�v�֐��������܂��B
% �f�t�H���g��'linear'�^�C�v�ł��B
%
% FIS = GENFIS1(DATA, NUMMFS, INPUTMF, OUTPUTMF) �͌����Ɏw�肵�܂��B
%
% NUMMFS    :�e���͂Ɋ֘A���郁���o�V�b�v�֐��̐����w�肵���x�N�g���ł��B
%            �e���͂ɑ΂��ē����̃����o�V�b�v�֐���^����Ƃ��́AnumMFs 
%            ��1�̐�����^����݂̂ō\���܂���B
% INPUTMF  :�e���͂Ɋւ��郁���o�V�b�v�֐��^�C�v���A�s��̊e�s�Ŏw�肵
%            �������z��ł��B�e���͂ɓ��������o�V�b�v�֐��^�C�v��p����
%            �Ƃ��ɂ́A1�s�̕�����ō\���܂���B���̊֐�(genfis1)�́A�p
%            �����[�^ numMFs �� inmftype ���A���̓����o�[�V�b�v�֐��p��
%            ���[�^�𐶐�����֐� genparam �ɒ��ړn���܂��B
% OUTPUTMF :�o�͂Ɋւ��郁���o�V�b�v�֐��^�C�v���w�肷�镶����ł��B��
%            ��^�C�v�̃V�X�e���Ȃ̂ŁA1�o�͂ƂȂ�܂��B�o�̓����o�V�b�v
%            �֐��^�C�v�́Alinear�A�܂��́Aconstant �łȂ���΂Ȃ�܂���B
%
% ���
%    data = [rand(10,1) 10*rand(10,1)-5 rand(10,1)];
%    numMFs = [3 7];
%    mfType = str2mat('pimf','trimf');
%    fismat = genfis1(data,numMFs,mfType);
%    [x,mf] = plotmf(fismat,'input',1);
%    subplot(2,1,1),plot(x,mf);
%    xlabel('input 1 (pimf)');
%    [x,mf] = plotmf(fismat,'input',2);
%    subplot(2,1,2),plot(x,mf);
%    xlabel('input 2 (trimf)');
%
% �Q�l    GENFIS2 ANFIS



%   Copyright 1994-2002 The MathWorks, Inc. 
