% RANDN   ���K���z�̗���
% 
% RANDN(N)�́A���ς�0�ŕ��U��1�A�W���΍���1�̐��K���z�����闐����v�f��
% ����N�sN��̍s����o�͂��܂��B
% RANDN(M,N)��RANDN([M,N])�́A������v�f�Ƃ���M�sN��̍s����o�͂��܂��B
% RANDN(M,N,P,...)�܂���RANDN([M,N,P...])�́A������v�f�Ƃ���z����o��
% ���܂��B
% RANDN���g�ł́A���s���邽�тɈقȂ�X�J���l���o�͂��܂��BRANDN(SIZE(A))
% �́AA�Ɠ����T�C�Y�ł��B
%
% RANDN�́A�^�������𐶐����܂��B�������ꂽ����́A������̏�ԂŌ��肳
% ��܂��BMATLAB�́A�N�����ɏ�Ԃ����Z�b�g����̂ŁA������������́A���
% ��ύX���Ȃ����蓯���ł���\��������܂��B
% 
% S = RANDN('state')�́A���K���z����������̌��݂̏�Ԃ��܂�2�v�f�̃x�N
% �g�����o�͂��܂��BRANDN('state',S)�́A��Ԃ�S�Ƀ��Z�b�g���܂��B
% RANDN('state',0)�́A�������������ԂɃ��Z�b�g���܂��B
% ����J�ɑ΂��ARANDN('state',J)�́A�������J�Ԗڂ̏�ԂɃ��Z�b�g���܂��B
% RANDN('state',sum(100*clock))�́A���s���ƂɈقȂ��ԂɃ��Z�b�g���܂��B
%
% MATLAB Version 4.x�́A�V���O���V�[�h�̗�����������g���Ă��܂����B
% RANDN('seed',0)��RANDN('seed',J)�́AMATLAB 4�̔�������g���܂��B
% RANDN('seed')�́AMATLAB 4�̐��K���z����������̌��݂̃V�[�h���o�͂�
% �܂��B
% RANDN('state',J)��RANDN('state',S)�́AMATLAB 5�̔�������g���܂��B
% 
% �Q�l�FRAND, SPRAND, SPRANDN, RANDPERM.


%   Copyright 1984-2002 The MathWorks, Inc.
%   $Revision: 1.8.4.1 $  $Date: 2004/04/28 01:51:42 $
%   Built-in function.
