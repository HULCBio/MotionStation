% RAND   ��l���z�̗���
% 
% RAND(N)�́A���(0.0,1.0)�Ɉ�l���z���闐����v�f�Ƃ���AN�sN��̍s���
% �o�͂��܂��B
% RAND(M,N)��RAND([M,N])�́A������v�f�Ƃ���M�sN��̍s����o�͂��܂��B
% RAND(M,N,P,...)�܂���RAND([M,N,P,...])�́A������v�f�Ƃ���z����o��
% ���܂��B
% RAND���g�ł́A���s���邽�тɈقȂ�X�J�����o�͂��܂��B
% RAND(SIZE(A))�́AA�Ɠ����T�C�Y�ł��B
%
% RAND�́A�^�������𐶐����܂��B�������ꂽ����́A������̏�ԂŌ��肳��
% �܂��BMATLAB�́A�N�����ɏ�Ԃ����Z�b�g����̂ŁA������������́A��Ԃ�
% �ύX���Ȃ����蓯�����̂ɂȂ�\��������܂��B
% 
% S = RAND('state')�́A��l����������̌��݂̏�Ԃ��܂ށA35�v�f�̃x�N�g
% �����o�͂��܂��B
% RAND('state',S)�́A��Ԃ�S�Ƀ��Z�b�g���܂��B
% RAND('state',0)�́A�����������������ԂɃ��Z�b�g���܂��B����J�ɑ΂��āA
% RAND('state',J)�́A�����������J�Ԗڂ̏�ԂɃ��Z�b�g���܂��B
% RAND('state',sum(100*clock))�́A���s���ƂɈقȂ��ԂɃ��Z�b�g���܂��B
% 
% ���̗���������́A���[2^(-53)�A1-2^(-53)]���̕��������_�������ׂĐ�
% �����邱�Ƃ��ł��܂��B���_�I�ɂ́A�����l���J��Ԃ��O�ɁA2^1492�ȏ�̒l
% �𐶐����邱�Ƃ��ł��܂��B
%
% MATLAB Version 4.x�ł́A�V���O���V�[�h�̗�����������g���Ă��܂����B
% RAND('seed',0)��RAND('seed',J)�́AMATLAB 4�̔�������g���܂��B
% RAND('seed')�́AMATLAB 4�̈�l����������̌��݂̃V�[�h���o�͂��܂��B
% RAND('state',J)��RAND('state',S)�́AMATLAB 5�̔�������g���܂��B
%
% �Q�l�FRANDN, SPRAND, SPRANDN, RANDPERM.


%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.8.4.1 $  $Date: 2004/04/28 01:51:41 $
%   Built-in function.
