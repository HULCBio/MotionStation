% LINSUB   SIMULINK�̃��f���̐��`����
%
% SYS = LINSUB('MODEL',HIN,HOUT) �́ASIMULINK ���f�� 'MODEL' �̒��̂���
% ���̃T�u�V�X�e���̐��`�����ꂽ��ԋ�ԃ��f���𓾂܂��B�T�u�V�X�e����
% ���͂́A�n���h�� HIN ������InputPoint �u���b�N�Œ�`����A�o�͂́A�n��
% �h�� HOUT ������ OutputPoint �u���b�N�Œ�`����܂��B��ԕϐ��Ɠ��͂�
% �[���ɐݒ肳��܂��B
%
% SYS = LINSUB('MODEL',HIN,HOUT,T,X,U) �́A����ɁA�S�̂̃��f���ɑ΂���
% ���`�������s����_ (T, X, U) ��ݒ肵�܂��B�����ŁA T �͎��ԁAX �͏��
% �ϐ����ƒl����Ȃ�\���́AU�͊O�����͂̃x�N�g���ł��BX = [] �܂��� 
% U = [] �́A�����̂Ȃ��傫���̃[���s���ݒ肵�܂��B
%
% ��ԕϐ��l��ݒ肷��ꍇ�A�\���̂͂���2�̃t�B�[���h��K�v�Ƃ��܂��B
%   
%   Names  = ��Ԗ��̃Z���z��
%   Values = ��Ԗ��̏��Ԃɏ]������Ԃ̒l��v�f�Ƃ���x�N�g��
%
% SYS = LINSUB('MODEL',HIN,HOUT,...,OPTIONS) �́A�ݒ肷��K�v�̂�����`��
% �I�v�V�����ł��BOPTIONS �́A���̃t�B�[���h�������\���̂ł��B
% 
%   SampleTime  - ���U�V�X�e���ɑ΂��Ďg�p����T���v�����O����(�f�t�H���g
%                 �́A�X�̃u���b�N�̃T���v�����O���Ԃ̍ŏ����{��)
%
% �Q�l : LINMOD, DLINMOD


%   Conversion to LINMOD: G. Wolodkin 12/15/1999
%   Authors: K. Gondoly, A. Grace, R. Spada, and P. Gahinet
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.6.4.1 $
