% RLOCFIND   �^����ꂽ���̑g�ɑ΂��鍪�O�ՃQ�C�����Z�o
%
% [K,POLES] = RLOCFIND(SYS) �́ARLOCUS �ɂ���č쐬���ꂽ SISO �V�X�e�� 
% SYS �̍��O�Ղ̃v���b�g����A�Θb�`���ɃQ�C����I�����邽�߂ɗp���܂��B
% RLOCFIND �́A���O�Տ�̋ɂ̈ʒu��I�����邽�߂ɗ��p����O���t�B�b�N
% �E�B���h�E��֏\���J�[�\�����ړ����Đݒ肵�܂��B���̓_�Ɋ֘A���鍪�O�Ղ�
% �Q�C���� K �ɏo�͂���A���̃Q�C���ɑ΂��邷�ׂẴV�X�e���̋ɂ� POLES ��
% �o�͂���܂��B
%
% [K,POLES] = RLOCFIND(SYS,P) �́A��]���鍪�̈ʒu�̃x�N�g�� P ���g���A
% �����̈ʒu���ꂼ��ɑ΂��č��O�ՃQ�C��(���Ȃ킿�A���[�v�̍��̈ʒu
% ����]����ʒu�ɋ߂��Ȃ�Q�C��)���v�Z���܂��B�x�N�g�� K �� j �Ԗڂ�
% �v�f�́A�ʒu P(j) �ɑ΂��Čv�Z���ꂽ�Q�C���ŁA�s�� POLES �� j �Ԗڂ�
% ��́A���ʋ��܂���[�v�̋ɂ������܂��B
%
% �Q�l�F    RLOCUS.


%   Clay M. Thompson  7-16-90
%   Revised ACWG 8-14-91, 6-21-92
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.7.4.1 $  $Date: 2003/06/26 16:04:44 $
