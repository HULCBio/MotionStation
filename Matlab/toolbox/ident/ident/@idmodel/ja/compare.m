% COMPARE �́A����o�͂ƁA�V�~�����[�V����/�\���o�͂��r���܂��B
% 
%   COMPARE(DATA,SYS,M)
%
%   DATA : ��r�ɗ��p�����o�� - ���̓f�[�^(IDDATA �I�u�W�F�N�g)
%          (���ؗp�̃f�[�^�Z�b�g)
%   SYS  : IDMODEL �I�u�W�F�N�g�t�H�[�}�b�g�ŕ\���ꂽ���f��
%
%   M    : �\����ԁB���� t-M �܂ł̏o�͂��A���� t �ł̏o�͂�\�����邽��
%          �Ɏg���܂��B���ׂĂ̊֘A������͂��g���܂��BM = inf �Ƃ���
%          �ƁA�V�X�e���̏����ȃV�~�����[�V���������s���܂�(�f�t�H���g��
%           M = inf �ł�)�B
%   YH   : ���ʂ̃V�~�����[�V����/�\���o��
% COMPARE  �́AZ �̒��̑���o�͂� YH ���v���b�g���܂��B�����āA�o�͂�
% �ω����A���f�����g���āA�ǂ̂��炢�����ł��邩�������܂��B
% COMPARE(DATA,SYS1,SYS2,...,SYSn,M) �́A�������̃��f�����r���܂��B��
% ���Ɏ����悤�ɁA�e�V�X�e���ɃJ���[�A���C���X�^�C���A�}�[�J��ݒ肷�邱
% �Ƃ��ł��܂��B
% 
%       COMPARE(DATA,sys1,'r',sys2,'y--',sys3,'gx').
%
% DATA �������̎������܂�ł���ꍇ�A�e�����ɑ΂��Ĉ�̃v���b�g���쐬��
% �邱�Ƃ��ł��܂��B
%
% COMPARE(DATA,SYS,..,SYSn,M,SAMPNR,INIT) �ɂ��A�������̃I�v�V������
% �A�N�Z�X���邱�Ƃ��ł��܂��B
%   SAMPNR : �v���b�g����T���v������FIT �̌v�Z�Ɏg�p����T���v�����ŁA
%             DATA �̃T���v�����ł�(�f�t�H���g�́ASAMPNR = DATA �̂��ׂ�
%             �̍s)�B
%             �����̎����f�[�^�ɑ΂��āASAMPNR �́A�����̐��Ɠ����̃T�C�Y
%             �����Z���z��ł��B
%   INIT   : ���f��/�\���q�̏�����Ԃ̎�舵��
%         INIT = 'e' (�f�t�H���g):�œK���̂��߂̏�����Ԃ̐���
%         INIT = 'm'             :���f���̓����ɃX�g�A����Ă��鏉�����
%                                  ���g�p
%         INIT = 'z'             :������Ԃ��[���ɐݒ�
%         INIT = X0�A�����ŁAX0 �́A��ԃx�N�g���Ɠ��������̗�x�N�g����
%                    ���B������Ԃ� X0 ���g�p���܂��B
% �\���̌v�Z���߂� DATA �̂��ׂĂ̏o�͂𗘗p���A�v���b�g�ɂ͂������̏o
% �݂͂̂𗘗p���邽�߂ɂ́A�Ō�̓��͈��� CHANNELS ���A�v���b�g�����
% DATA �� OutputNames �̃Z���z��Ƃ��Ēǉ����܂��B
% COMPARE(DATA,SYS,{'y2'})
%
% [YH,FIT] = COMPARE(DATA,SYS,..,SYSn,M,SAMPNR,INIT) �́A�v���b�g���s����
% ����B�������A���f���o�� YH �ƃ��f���̑���o�͂��A�ǂ̂��炢�����ł���
% �������� FIT(%�\��)���o�͂��܂��BYH �́A�X�̃��f���ɑ΂��ďo�͂����
% �X�� IDDATA �f�[�^�Z�b�g�̃Z���z��ł��BFIT �́A���� Kexp �A���f�� Km
% ad�A�o�� Ky �ɑ΂���K���x�������܂� FIT(Kexp,Kmod,Ky) ��v�f�Ƃ���3��
% ���z��ł��B
% 
% �Q�l�F IDMODEL/IDSIM, PREDICT

%   L. Ljung 10-1-89,10-10-93


%   Copyright 1986-2001 The MathWorks, Inc.
