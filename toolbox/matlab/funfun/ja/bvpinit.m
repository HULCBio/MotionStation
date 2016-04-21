% BVPINIT  BVP4C�p�̏���������s���܂��B
% 
% SOLINIT = BVPINIT(X,YINIT)�́A��ʓI�Ȋ��ŁABVP4C�p�̏���������s��
% �܂��BBVP�́A���[a,b]�ŉ�����܂��B�x�N�g��X�́AX(1) = a, X(end) = b
% �̂悤��a��b���w�肵�܂��B�K�؂ȃ��b�V���ɑ΂��鐄��ɂ��Ȃ�܂��BBVP4C
% �́A���̃��b�V������@�Ɏg���܂��B����ŁAx = logspace(a,b,10)�̂悤��
% ����ł��\���ł����A���G�ȏꍇ�́A���b�V���_�́A�����}���ɕω�����ꏊ
% �ɐݒ肵�Ȃ���΂Ȃ�܂���B
%
% X �͏����ł���K�v������܂��B2�_ BVP �ɂ����ẮAX �̗v�f�͋�ʂ���A
% a < b �̏ꍇ�AX(1) < X(2) < ... < X(end)�̂悤�ɏ����t�����Ă���K�v
% ������܂��B���_ BVP �̏ꍇ�́A[a,b] �ɂ����Ă������̋��E����������܂��B
% ��ʓI�ɁA�����̓_�̓C���^�t�F�[�X��\�킵�A[a,b] �̈�ɂ����Ď��R��
% ��������܂��BBVPINIT �͗̈�ɑ΂��č�����E( a ���� b)�ɗ^�����A
% �C���f�b�N�X�� 1 ����X�^�[�g���܂��B�C���^�t�F�[�X�͏������b�V�� X ��
% �_�u���G���g���[�Ŏw��ł��܂��BBVPINIT �́A1�߂̃G���g���[��̈� k 
% �̉E�I�_�A������̈� k+1 �̍��I�_�Ƃ��ĉ��߂��܂��BTHREEBVP �́A3�_ BVP 
% �̗��ł��B
% 
% YINIT�́A���ɑ΂��鐄��ł��B���̐���ɑ΂��āA�����������Ƌ��E������
% �v�Z���邱�Ƃ��ł��Ȃ���΂Ȃ�܂���BYINIT�́A�x�N�g���A�܂��́A�֐�
% �̂����ꂩ�ł��\���܂���B
% 
% �x�N�g���FYINIT(i)�́AX���̂��ׂẴ��b�V���_�ł̉���i�Ԗڂ̗v�fY(i,:)
% �̒萔����ł��B
%
% �֐�: YINIT �́A�X�J�� x �̊֐��ł��B���Ƃ��΁A��� [a,b] �̔C��
%       �̒l x �ɑ΂��āAyfun(x) ���A�� y(x)�ɑ΂��鐄���߂��ꍇ
%       solinit = bvpinit(x,@yfun) ���g���܂��B
%     
% SOLINIT = BVPINIT(X,YINIT,PARAMETERS) �́ABVP �����m�p�����[�^���܂ނ�
% �Ƃ��Ӗ����Ă��܂��B����́A�x�N�g�� PARAMETERS �̒��̂��ׂẴp�����[
% �^�ɑ΂��ėp�ӂ���܂��B
%
% SOLINIT = BVPINIT(X,YINIT,PARAMETERS,P1,P2...) �́A�t���I�Ȋ��m�p�����[
% �^ P1,P2,... �� YINIT(X,P1,P2...) �Ƃ��āA����֐��ɓn���܂��B 
% ���m�p�����[�^�����݂���ꍇ�ASOLINIT = BVPINIT(X,YINIT,[],P1,P2...) ��
% �g���܂��B�p�����[�^ P1,P2,... �́AYINIT ���֐��̏ꍇ�ɂ̂ݎg���܂��B 
% 
% SOLINIT = BVPINIT(SOL,[ANEW BNEW]) �́A���[a,b]��̉� SOL ����A���
% [ANNEW,BNEW]��ł̏���������쐬���܂��B�V������Ԃ́A���L���Ȃ���
% �΂Ȃ�܂���B���Ȃ킿�AANEW <= a < b <= BNEW�A�܂��́A
% ANEW >= a > b >= BNEW �̂ǂ��炩�𖞂����K�v������܂��B
% ��SOL�́A�V������ԂɊO�}����܂��B���݂���ꍇ�́ASOL ���� PARAMETERS
% �́A SOLINIT ���g���܂��B
% 
% SOLINIT = BVPINIT(SOL,[ANEW BNEW],PARAMETERS) �́A��ŋL�q���� SOLINIT 
% ���쐬���܂��B�������A���m�̃p�����[�^�Ɋւ��ẮA����l�Ƃ���PARAMETERS
% ���g���܂��B
%
% �Q�l�FBVPGET, BVPSET, BVP4C, DEVAL, @

%   Jacek Kierzenka and Lawrence F. Shampine
%   Copyright 1984-2003 The MathWorks, Inc. 
