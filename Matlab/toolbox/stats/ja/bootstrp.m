% BOOTSTRP   �u�[�g�X�g���b�v���v��
%
% BOOTSTRP(NBOOT,BOOTFUN,...) �́ANBOOT ��̃u�[�g�X�g���b�v�f�[�^�W�{��
% �\�����A�֐� BOOTFUN ���g���āA��������͂��܂��B���� NBOOT �́A����
% �����łȂ���΂Ȃ�܂���B3�ԖڂƂ���ȍ~�̈����́A�f�[�^�ł��B
% BOOTSTRP �́A�f�[�^�̃u�[�g�X�g���b�v�T���v���� BOOTFUN �ɓn���܂��B
% 
% [BOOTSTAT,BOOTSAM] = BOOTSTRP(...) �ɂ����āA���� BOOTSTAT �́A���
% �u�[�X�g���b�v�T���v���� BOOTFUN �̌��ʂ��܂񂾂��̂ɂȂ��Ă��܂��B
% BOOTFUN ���s����o�͂���ꍇ�A���̏o�͂́ABOOTSTAT �̒��̃X�g���[�W��
% �ۊǂ��邽�߂Ɉ�̒����x�N�g���ɕϊ�����܂��B���� BOOTSAM �́A
% �f�[�^�s��̍s�̎w�W�ƂȂ�s��ł��B
% 
% ���F
% �����_���T���v����100��̃u�[�X�g���b�v�̕��ς̃T���v�����x�N�g�� Y 
% ����쐬���܂��B
% 
%       M = BOOTSTRP(100, 'mean', Y)
% 
% �x�N�g�� Y �̍s�� X �ւ̉�A�p�ɁA200��̃u�[�X�g���b�v���s�����W��
% �x�N�g���̃T���v�����쐬���܂��B
% 
%      B = BOOTSTRP(200, 'regress', Y, X)
% 


%   B.A. Jones 9-27-95, ZP You 8-13-98
%   Copyright 1993-2002 The MathWorks, Inc. 
%   $Revision: 1.6 $  $Date: 2003/02/12 17:10:28 $
