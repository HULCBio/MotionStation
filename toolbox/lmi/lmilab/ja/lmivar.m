% X = lmivar(type,struct)
% [X,ndec,Xdec] = lmivar(type,struct)
%
% �J�����g�ɋL�q����Ă���A��LMI�ɁA�V�����s��ϐ�X��ǉ����܂��B���x��
% X�́A���̐V�����ϐ�����ŎQ�Ƃ���Ƃ��ɗ��p���邽�߂ɁA�I�v�V�����ŕt
% ������܂��B
%
% ����:
%  TYPE     X�̍\��:
%		  1 -> �u���b�N�Ίp�\�������Ώ̍s��
%		  2 -> �t�������s��
%		  3 -> ���̑��̍\��
%  STRUCT   X�̍\���ɕt������f�[�^
%        TYPE=1: STRUCT��i�Ԗڂ̍s�́AX��i�Ԗڂ̑Ίp�u���b�N���L�q���܂��B
%                STRUCT(i,1) -> �u���b�N�T�C�Y
%                STRUCT(i,2) -> �u���b�N�^�C�v�B���Ȃ킿
%                                   0  �X�J���u���b�Nt*I
%                                   1  �t���u���b�N
%                                   -1 �[���u���b�N
%        TYPE=2: X��M�sN��s��Ȃ�΁ASTRUCT = [M,N]�B
%        TYPE=3: STRUCT�́AX�Ɠ��������̍s��ł��B
%                �����ŁASTRUCT(i,j)�́A���̂����ꂩ�ł��B
%                    X(i,j) = 0�̂Ƃ��A0
%                    X(i,j) = n�Ԗڂ̌���ϐ��̂Ƃ��A+n
%                    X(i,j) = (-1)* n�Ԗڂ̌���ϐ��̂Ƃ��A-n
% �o��:
%  X        �I�v�V����: �V�K�̍s��ϐ��ɑ΂��鎯�ʎq�B
%           k-1�̍s��ϐ������łɐ錾����Ă���΁A���̒l��k�ƂȂ�܂��B
%           ���̎��ʎq�́ALMI�̕ύX�ɂ���ĉe�����󂯂܂���B
%  NDEC     ����ϐ��̑����B
%  XDEC     X�̗v�f�P�ʂ̌���ϐ��Ƃ̊֌W(Xdec = Type 3�ɑ΂���\��)�B
%
% �Q�l�F    SETLMIS, LMITERM, GETLMIS, LMIEDIT, DECINFO.



% Copyright 1995-2002 The MathWorks, Inc. 
