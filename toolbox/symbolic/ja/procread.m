% PROCREAD   Maple �v���V�[�W���̑}��
% PROCREAD(FILENAME) �́A�w��̃t�@�C����ǂݍ��݂܂��B�����ŁA�t�@�C��
% �� Maple �v���V�[�W���̃\�[�X�e�L�X�g���܂�ł��܂��BPROCREAD �́A�R��
% ���g�� newline ��������菜���Ă���A���ʂ̕������ Maple �ɓ]�����܂��B
% PROCREAD ���g�p����ɂ́AExtended Symbolic Toolbox ���K�v�ł��B
%
% ���:
% �t�@�C�� "check.src" �ɁA�ȉ��� Maple �v���V�[�W���̃\�[�X�e�L�X�g����
% �܂�Ă���Ɖ��肵�܂��B
%
%         check := proc(A)
%            #   check(A) computes A*inverse(A)
%            local X;
%            X := inverse(A):
%            evalm(A &* X);
%         end;
%
% �X�e�[�g�����g
%
%         procread('check.src')
%
% �́A�v���V�[�W����ǂݍ��݂܂��B�ȉ��̃R�}���h�ŁA���̃v���V�[�W���ɃA
% �N�Z�X�ł��܂��B
%
%         maple('check',magic(3))
%
% �܂��́A
%
%         maple('check',vpa(magic(3)))
%
% �Q�l   MAPLE.



%   Copyright 1993-2002 The MathWorks, Inc. 
