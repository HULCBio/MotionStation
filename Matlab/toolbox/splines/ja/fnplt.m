% FNPLT   �֐��̃v���b�g
%
% FNPLT(F) �́AF �ɂ���֐�����{��ԂŃv���b�g���܂��B
%
% FNPLT(F,SYMBOL,INTERV,LINEWIDTH,JUMPS) �́A�w�肵�� INTERV = [a,b] 
% (�f�t�H���g�͊�{��ԁj�ɂ�����֐� F ���A�w�肵�� SYMBOL�i�f�t�H���g�� 
% '-')�� LINEWIDTH (�f�t�H���g��1)��p���ăv���b�g���܂��B����ɁAJUMPS ��
% 'j' �ł͂��܂镶����ł���ꍇ�̂݁A��т����ۂ̔�тƂ��Ď������߂ɁA
% NaN ���g�p���ăv���b�g���܂��B
%
% 4�̃I�v�V�����������A�C�ӂ̏����ŕ��ׂ邱�Ƃ��ł��܂��BINTERV �́A
% [1 2] �̑傫���ŁASYMBOL �� JUMPS �͕�����ŁALINEWIDTH �̓X�J���ł��B
% ��̃I�v�V���������́A���������������܂��B
%
% F �ɂ���֐���2�v�f�̃x�N�g���l�̏ꍇ�A���ʋȐ����v���b�g����܂��B
% F �ɂ���֐����Ad>2 �ł���d�v�f�̃x�N�g���l�̏ꍇ�AF �̍ŏ���3������
% ����ė^�������ԋȐ����v���b�g����܂��B
%
% �֐������ϐ��̏ꍇ�A�t���I�ȕϐ��ɂ��Ă͊�{��Ԃ̒��ԓ_���g���āA
% 2�ϐ��֐��Ƃ��ăv���b�g����܂��B
%
% POINTS = FNPLT(F,...) �́A�v���b�g�͂��܂��񂪁A2�����̓_�܂���3������
% �_�̗� F(T) ���o�͂��܂��B
%
% [POINTS, T] = FNPLT(F,...) �́A�x�N�g���l F �ɑ΂��āA�Ή�����p�����[�^
% �l�̃x�N�g�� T ���o�͂��܂��B
%
% ���:
%      x=linspace(0,2*pi,21); f = spapi(4,x,sin(x));
%      fnplt(f,'r',3,[1 3])
%
% �́A�ԐF�Ő��̕���3�Ƃ��āA��� [1 .. 3] �ł� f �ɂ���֐��̃O���t��
% �v���b�g���܂��B


%   Copyright 1987-2003 C. de Boor and The MathWorks, Inc.
