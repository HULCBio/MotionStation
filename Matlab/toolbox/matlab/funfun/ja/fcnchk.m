% FCNCHK   FUNFUN�֐��̈����̃`�F�b�N
% 
% FCNCHK(FUN,...)�́A������ FUN �����ʁA�ϐ��A���w���Z�q���܂ނ��ǂ�����
% ���A�֐���������������܂��̓C�����C���I�u�W�F�N�g���o�͂��܂��BFC-
% NCHK �́AFUN ���֐��n���h���A���O�̕�����(���Ƃ��΁A'sin')�A�܂��́A
% feval ���g���� matlab �I�u�W�F�N�g(���Ƃ��΁A�C�����C���I�u�W�F�N�g)��
% �����ꂩ�̏ꍇ�AFUN ���o�͂��܂��B
%
% FCNCHK�́AFMINBND, FMINSEARCH, FZERO���̕⏕�֐��Ȃ̂ŁAm-�t�@�C���֐�
% �ɉ����āA������\�����g���Čv�Z�ł��܂��B
%
% FCNCHK(FUN,...,'vectorized')�́A�x�N�g�������ꂽ�֐����쐬���邽�߂ɁA
% ��������������܂�(���Ƃ��΁A'*'��'.*'�Œu�������܂�)�B
%
% FUN�������܂ނƂ��AFCNCHK(FUN,...)�́A�x�N�g�����֐����쐬���邽�߂Ɏg
% �p�����I�v�V�����̌�ɑ�������'vectorized'�������΁AINLINE(FUN,...)
% �Ɠ����ł��B
%
% [F,MSG] = FCNCHK(...)�́A����I�������MSG�ɋ�\���̂��o�͂��A�����ł�
% ����΃G���[���b�Z�[�W�\���̂��o�͂��܂��B
%
%   �Q�l ERROR, INLINE, @.

%   Copyright 1984-2003 The MathWorks, Inc.

