% COLFILT   ����������֐����g���āA�ߖT���Z�����s
% COLFILT �́A�X�̃u���b�N�A�܂��́A�X���C�f�B���O�u���b�N���Ƃ��ď�
% �����܂��BCOLFILT �́ABLKPROC �� NLFILTER �Ɠ��l�̉��Z���s���܂����A
% ���ɍ����ɂȂ�܂��B
% 
% B = COLFILT(A,[M N],BLOCK_TYPE,FUN) �́A�C���[�W A ���A�X�� M �s N ��
% �̃u���b�N�ɍĔz�񂵂āA�e���|�����̍s��̗�ɕ��ёւ��ď������܂��B��
% ���āA�֐� FUN �����̍s��ɓK�p���܂��BFUN �́A@�܂��́AINLINE �I�u�W
% �F�N�g���g���č쐬���� FUNCTION_HANDLE �ł��B
% COLFILT �́A�K�v�Ȃ� A �Ƀ[����t�����܂��B
% 
% FUN ���Ăяo���O�ɁACOLFILT �́A�e���|�����s����쐬���邽�߂ɁAIM2COL
% ���Ăяo���܂��BFUN ���Ăяo������ACOLFILT �́ACOL2IM ���g���āA�s��
% �̗�� M �s N ��̃u���b�N�ɕ��ёւ��܂��B
% 
% BLOCK_TYPE �ɂ́A���̂����ꂩ�̒l��ݒ肷�邱�Ƃ��ł��܂��B
% 
% 'distinct' �́AM �s N ��̏d�Ȃ�̂Ȃ��u���b�N
% 'sliding' �́AM �s N ��̃X���C�f�B���O�u���b�N
% 
% B = COLFILT(A,[M N],'distinct',FUN) �́AA �� M �s N ��̃u���b�N���e��
% �|�����s��ɍĔz�񂵁A���̍s��Ɋ֐� FUN ��K�p���܂��BFUN �́A�e���|
% �����s��Ƃ��āA���T�C�Y�̍s����o�͂��܂��B�����āACOLFILT �́AFUN ��
% �o�͂���s��̗���AM �s N ��̃u���b�N�ɍĔz�񂵂܂��B
% 
% B = COLFILT(A,[M N],'sliding',FUN) �́AA �̊e M �s N ��̃X���C�f�B���O
% �ߖT����בւ��āA�e���|�����s��̗�ɂ��܂��B�����āA�֐� FUN ������
% �s��ɓK�p���܂��BFUN �́A�e���|�����s����̊e��ɑ΂��āA�P��l���܂�
% �s�x�N�g�����o�͂��Ȃ���΂Ȃ�܂���(SUM �̂悤�ȗ񈳏k�֐��́A�K�؂�
% �^�C�v�̏o�͂�Ԃ��܂�)�BCOLFILT �́AFUN ���o�͂���x�N�g���� A �Ɠ��T
% �C�Y�̍s��ɍĔz�񂵂܂��B
% 
% B = COLFILT(A,[M N],BLOCK_TYPE,FUN,P1,P2,...) �́A�t���I�ȃp�����[�^ P1
% P2,...,�� FUN �ɓn���܂��BCOLFILT �́A���̂悤�� FUN ���Ăяo���܂��B
% 
%    Y = FUN(X,P1,P2,...)
% 
% �����ŁAX �͏����O�̃e���|�����s��ŁAY �͏�����̃e���|�����s��ł��B
% 
% B = COLFILT(A,[MN],[MBLOCKNBLOCK],BLOCK_TYPE,FUN,...) �́A��q�̂悤��
% �s�� A ���������܂����A��������ߖ񂷂邽�߁AMBLOCKS �s NBLOCKS ��̑�
% �����̃u���b�N���g���܂��B[MBLOCK  NBLOCK] �������g�����Ƃ́A���Z����
% �ɉe����^���܂���B
% 
% B = COLFILT(A,'indexed',...) �́AA ���C���f�b�N�X�t���C���[�W�Ƃ��ď�
% �����AA ���N���X uint8�A�܂��́Auint16 �̏ꍇ0�A�N���X double �̏ꍇ1
% ��K�v�ɉ����ĕt�����܂��B
% 
% �N���X�T�|�[�g
% -------------
% ���̓C���[�W A �ɂ́AFUN ���T�|�[�g����N���X���g�����Ƃ��ł��܂��BB 
% �̃N���X�́AFUN ����o�͂����N���X�Ɉˑ����܂��B
% 
% ���
%       I = imread('tire.tif');
%       imshow(I)
%       I2 = uint8(colfilt(I,[5 5],'sliding',@mean));
%       figure, imshow(I2)
%
% �Q�l�FBLKPROC, COL2IM, FUNCTION_HANDLE, IM2COL, INLINE, NLFILTER.



%   Copyright 1993-2002 The MathWorks, Inc.  
