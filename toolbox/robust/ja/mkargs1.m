% MKARGS1 �́A(MKARGS ���g����)MKSYS �ō쐬���ꂽ���͈������g�債�܂��B
%
% [FLAG,NARG,O1,...,ON] = MKARGS1(TY,I1,...,IM) �́AMKARGS �Ŏg�p�����T
% �u���[�`���ł��B���͈������X�g I1,...,IM ���A�o�͈����̑Ή�����ʒu�ɒ�
% �`�����s���}�����邱�ƂŁA���͈����̒��Ō�������e SYSTEM ���g�傷
% �邽�߂ɁA�o�͈������X�g O1,...ON �ɃR�s�[����܂��B�o�͈��� NARG �́A�V
% �X�e���̓W�J�̌�A���͈��� I1,...,IM �̐����o�͂��܂��B(NARG �̌��ɑ�
% ��)�G�N�X�g���o�͈��� O1,...,ON �́ANaN �Ƃ��ďo�͂���܂��B�g���ɕK�v��
% ���̏o�͈������ɐݒ肪����Ȃ��ꍇ�A�֐��́A�G���[�𐶂��ďI�����܂��B
%
% �I�v�V�������� TY �́A���݂��Ă���ꍇ�A���҂������A���Ƃ��΁ATY = 
% 'ss,tss' �Ő�����悤�ȃV�X�e���ɑ΂���g�p�ł���V�X�e����ݒ肵�܂��B
% EVAL(CMD)�����s���ꂽ�ꍇ�A�ݒ肵���^�C�v�ȊO�̃V�X�e���ɏo������ꍇ�A
% �G���[�������܂��B
%
% ���F
%     SS_G = MKSYS(A,B,C,D), W=logspace(-2,2), Z='foobar' �̏ꍇ�A
% 
% [O1,O2,O3,O4,O5,O6,O7,O8] = MKARGS1('',Z,SS_G,W) �́A���̏o�͂��s����
% ���B
% 
%    NARG=6, O1=Z, O2=A, O3=B, O4=C, O5=D, O6=W, O7=NaN, O8=NaN.

% Copyright 1988-2002 The MathWorks, Inc. 
