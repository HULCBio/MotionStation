% COPYOBJ   �O���t�B�b�N�X�I�u�W�F�N�g�Ƃ��̎q�̃R�s�[�̍쐬
% 
% C = COPYOBJ(H,P) �́A�x�N�g�� H �̃n���h���ԍ��ɂ���Ďw�肳���
% �O���t�B�b�N�X�I�u�W�F�N�g�̃R�s�[���쐬���܂��B���̃I�u�W�F�N�g�́A
% �x�N�g�� P �Ŏw�肳�ꂽ�I�u�W�F�N�g�̎q�ŁAlength(H) �̐V�����I�u�W�F
% �N�g���g���āA�x�N�g�� C �Ƀn���h���ԍ����o�͂��܂��B�R�s�[�́A'Parent'
% �v���p�e�B�� P �ɑΉ�����悤�ɕύX���ꂽ���ƈȊO�́AH �ŎQ�Ƃ����
% �I�u�W�F�N�g�Ɠ����ł��B:
%     C(i) �́AP(i) �̎q�ł���H(i) �̃R�s�[�ł��B
% H �� P �́A���������ŁAH(i) �� P(i) �̑g�́A�e/�q�̊֌W�Ɋւ��ėL����
% �^�C�v�łȂ���΂Ȃ�܂���B����ȊO�ł́A�R�s�[�͍쐬����܂���B
%
%    C = COPYOBJ(H�Ap)
% 
% H ���x�N�g���ŁAp ���X�J���̏ꍇ�AH �̊e�I�u�W�F�N�g�̓R�s�[����A
% length(H) �̐V�����I�u�W�F�N�g���g���āAp �Ŏw�肳�ꂽ�I�u�W�F�N�g�̎q
% �ɂȂ�܂��B
% 
%   C = COPYOBJ(h�AP)
% 
% h ���X�J���ŁAP ���x�N�g���̏ꍇ�A�x�N�g�� P �̊e�I�u�W�F�N�g�̎q��
% ���āAlength(P) �̐V�����I�u�W�F�N�g���g���āA�I�u�W�F�N�gh�̃R�s�[��
% �쐬����܂��B
%   
% �Q�l�FFINDOBJ.


%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.9.4.1 $  $Date: 2004/04/28 01:55:38 $
%   Built-in function.
