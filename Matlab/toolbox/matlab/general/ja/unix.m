% UNIX   UNIX�R�}���h�̎��s�ƌ��ʂ̏o��
% 
% [status,result] = UNIX('command') �́AUNIX�V�X�e���ɂ����āA�^����ꂽ
% command �����s���邽�߂ɃI�y���[�e�B���O�V�X�e�����Ăяo���܂��B����
% �̃X�e�[�^�X�ƕW���o�͂��o�͂���܂��B
%
% ���:
%
%     [s,w] = unix('who')
%
% �́As = 0 �ƁA���݃��O�C�����Ă��郆�[�U�̃��X�g���܂�MATLAB������� w ��
% �o�͂��܂��B
%
%     [s,w] = unix('why')
%
% �́A'why' ��UNIX�R�}���h�ł͂Ȃ����߁A���s�̎��s��\�킷��[���̒l�� s
% �ɁA������ w ����s��ɐݒ肵�܂��B
%
%     [s,m] = unix('matlab')
%
% �́AMATLAB��2�ڂ̃R�s�[�̎��{���A������Ă��Ȃ��Θb�I�ȃ��[�U
% ���͂�K�v�Ƃ���̂ŁA�����o�͂��܂���B
% 
% �Q�l�F SYSTEM, PUNCT �̉��ł� ! (���Q��) 


%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.10.4.1 $  $Date: 2004/04/28 01:53:41 $
%   Built-in function.
