% WAITBAR   �E�G�C�g�o�[�̕\��
% 
% H = WAITBAR(X,'title', property, value, property, value, ...) �́A
% �������S�̂� X �̊����ł���E�G�C�g�o�[���쐬���āA�\�����܂��B�E�G�C�g
% �o�[�� figure �̃n���h���ԍ��́AH �ɏo�͂���܂��B
% 
% X �́A0��1�̊Ԃ̐��l�ł��B�I�v�V�����̈����v���p�e�B�ƒl�́A�Ή�����
% �E�G�C�g�o�[figure�v���p�e�B��ݒ肵�܂��B�v���p�e�B�́A�L�����Z��
% �{�^���� figure �ɉ�������ꍇ�A�����������L�[���[�h' CreateCancelBtn' 
% �ɂȂ�܂��B�����āA�n���ꂽ�l�̕�����́A�L�����Z���{�^�����A�܂��́A
% �t�B�M���A�N���[�Y�{�^�����N���b�N���邱�ƂŁA���s���܂��B
% 
% WAITBAR(X) �́A�ł��V�����쐬���ꂽ�E�G�C�g�o�[�E�B���h�E�Ƀo�[�̒���
% ��S�̂� X �̊����Őݒ肵�܂��B
%
% WAITBAR(X,H) �́A�E�G�C�g�o�[ H �̒��ɁA���̒����̊����� X �̃o�[�̒�
% ���������̂�ݒ肵�܂��B
%
% WAITBAR(X,H,'updated title') �́A�����̊������S�̂� x �ɂȂ�E�G�C�g�o�[
% ��ݒ肵�A���� figure �E�B���h�E�̃^�C�g���e�L�X�g���X�V���܂��B
%
% WAITBAR �́A�����v�Z���s�� FOR ���[�v���Ŏg�p����܂��B�g�p�@�̗��
% �ȉ��Ɏ����܂��B
%
%       h = waitbar(0,'Please wait...');
%       for i=1:100,
%           % �v�Z�����s�� %
%           waitbar(i/100,h)
%       end
%       close(h)


%   Clay M. Thompson 11-9-92
%   Vlad Kolesnikov  06-7-99
%   Copyright 1984-2002 The MathWorks, Inc.
%   $Revision: 1.8.4.1 $  $Date: 2004/04/28 02:09:11 $
