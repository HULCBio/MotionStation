% INVFREQS ���g�������f�[�^�ɍŏ����I�ɋߎ������A�i���O�t�B���^
%
% [B,A] = INVFREQS(H,W,nb,na)�́A�ݒ肵������ nb �� na �����`�B�֐���
% �������q B �ƕ��� A ���o�͂��܂��B�����ŁAH�́A���W�A���P�ʂŐݒ肵��
% ���g���x�N�g��W�̊e�v�f�ł̊�]���镡�f���g�������ł��BINVFREQS�́A��
% ���̌W�������t�B���^��݌v���܂��B���̂��Ƃ́A���̎��g���݂̂�ݒ肷
% ��Ώ\���ł��邱�Ƃ��Ӗ����Ă��܂��B�����t�B���^�ɑ΂��āA�K�؂Ȏ��g��
% �̈�ł̑Ώ̐���ۑ����邽�߁A���̎��g�� -W��conj(H)�ɋߎ�����悤�ɂ�
% �܂��B
%
% [B,A] = INVFREQS(H,W,nb,na,Wt)�́A���g���ɑ΂���ߎ��덷�ɏd�݂�t����
% ���B
% 
%   LENGTH(Wt) = LENGTH(W) = LENGTH(H)�B
% 
% �ΏۂƂȂ���g���ш�W�S�̂ɂ킽��A�덷�̓��a |B-H*A|^2*Wt���ŏ��ɂ�
% ��悤��A,B�����߂܂��B 
%
% [B,A] = INVFREQS(H,W,nb,na,Wt,ITER)�́A���̋ߎ��@���s���܂��B���� ITER
% �Őݒ肵�Ă���J��Ԃ��̒��ŁA���l�I�ȒT���ɂ��A�덷�̓��a|B-H*A|
% ^2*Wt��B��A�̌W���Ɋւ��čŏ��ɂ���悤�ɂ��܂��BA-�������͈���ł���
% ���Ƃ����肵�Ă��܂��B[B,A] = INVFREQS(H,W,nb,na,Wt,ITER,TOL) �́A���z
% �x�N�g���̃m������TOL�����ɂȂ������A�������I�������܂��B�f�t�H���g��
% TOL�� 0.01 �ɐݒ肳��܂��B�f�t�H���g��Wt�͂��ׂĂ�1�̏d�݃x�N�g���ɐ�
% �肳��Ă��܂��B�f�t�H���g�̒l�́AWt = [] ���g���Đݒ肵�܂��B
%
% [B,A] = INVFREQS(H,W,nb,na,Wt,ITER,TOL,'trace') �́A�����̐i�s�󋵂�
% ���ŕ\�����܂��B 
%
% [B,A] = INVFREQS(H,W,'complex',NB,NA,...)�́A���f���t�B���^��݌v����
% ���B���̏ꍇ�A�t�B���^�W���̑Ώ̐��͕ۏ؂���܂���B
%
% �Q�l�F   FREQZ, FREQS, INVFREQZ.



%   Copyright 1988-2002 The MathWorks, Inc.
