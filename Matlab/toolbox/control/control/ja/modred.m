% MODRED   ���f���̏�Ԃ̒᎟����
%
%
% RSYS = MODRED(SYS,ELIM) �́A�x�N�g�� ELIM �Ŏw�肳�ꂽ��Ԃ��폜���邱�ƂŁA
% ��ԋ�ԃ��f�� SYS �̒᎟�������s���܂��B���S�ȏ�ԃx�N�g�� X �́A
% X = [X1;X2] �ƕ�������܂��B�����ŁAX2 �́A�폜������Ԃł���A�᎟����
% ���ꂽ ��Ԃ́AXr = X1+T*X2 �Ɛݒ肳��܂��B T �́ASYS �� RSYS �� DC �Q�C��
% (����ԉ���) ����v����悤�ɑI�΂�܂��B
%
% ELIM �́AX �Ɠ����傫���̃C���f�b�N�X�x�N�g���܂��͘_���x�N�g���ɂȂ�܂��B
% �����ŁA�l TRUE �́A�폜������Ԃ������܂��BI/O �����ɖ����ł����^����
% �Ȃ���Ԃ��ŏ��ɕ������邽�߂ɂ́ABALREAL ���g�p���Ă��������BSYS ��
% BALREAL �ɂ�蕽�t������AHankel ���ْl�̃x�N�g�� G �� M �������v�f������
% �ꍇ�AMODRED ���g�p���āA�Ή����� M ��Ԃ��������Ƃ��ł��܂��B
% ��:
%   [sys,g] = balreal(sys)   % ���t�����ꂽ�������v�Z���܂�
%   elim = (g<1e-8)          % g �̏������v�f -> �����ł�����
%   rsys = modred(sys,elim)  % �����ł����Ԃ������܂�
%
% RSYS = MODRED(SYS,ELIM,METHOD) �́A��Ԃ̍폜���@���w�肵�܂��B
% �@
% METHOD �Ƃ��Ă��̂��̂𗘗p�ł��܂��B
%   'MatchDC' :  ��v���� DC �Q�C�� (�f�t�H���g)
%   'Truncate':  X2 ��P�ɍ폜���A Xr = X1 �Ɛݒ�
% �I�v�V���� 'Truncate' �́A���g���̈�ł��ǂ��ߎ�������X��������܂����A
% DC �Q�C���̈�v�͕ۏ؂���Ă��܂���B
%
% �Q�l : BALREAL, SS.


% Copyright 1986-2002 The MathWorks, Inc.
