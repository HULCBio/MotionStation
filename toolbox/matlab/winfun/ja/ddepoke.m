% DDEPOKE �A�v���P�[�V�����Ƀf�[�^��]��
% 
% DDEPOKE�́ADDE�ʐM�ɂ���ăA�v���P�[�V�����Ƀf�[�^��]�����܂��B
% DDEPOKE�́A�T�[�o�A�v���P�[�V�����Ƀf�[�^��]������O�ɁA���̂悤��
% �f�[�^�s����t�H�[�}�b�g���܂��B
% 
%   * �����s��͗v�f���ɃL�����N�^�ɕϊ�����A�ϊ���̃L�����N�^�o�b�t�@
%     ���]������܂��B
%   * ���l�s��́A����^�u��؂�ŁA�s���L�����b�W���^�[���⃉�C���t�B�[�h
%     ��؂�œ]������܂��B�X�p�[�X�ł͂Ȃ��s��̎������݂̂��]������܂��B
%
%    rc = DDEPOKE(channel,item,data,format,timeout)
%
% rc      �Ԃ�l: 0�͎��s�A1�͐������Ӗ����܂��B
% channel DDEINIT����̒ʐM�`�����l��
% item    �f�[�^�]���̂��߂̃f�[�^�A�C�e�����w�肷�镶����Bitem�́Adata
%         �����ŁA�]�������f�[�^���܂ނ��߂̃T�[�o�f�[�^���g�ł��B
% data    �]������f�[�^���܂񂾍s��
% format  (�I�v�V�����I��)�v�����ꂽ�f�[�^�`�����w�肷��X�J���l�B�f�[�^
%         �]���Ɏw�肷��Windows�N���b�v�{�[�h�`����\���܂��B���݂́ACF_
%         TEXT�̂݃T�|�[�g���Ă��āA�l1�ɑΉ����܂��B
% timeout (�I�v�V�����I��)�I�y���[�V�����̐������Ԃ��w�肷��X�J���l�B��
%         �����Ԃ́A1000����1�b�P�ʂŎw�肵�܂��B�f�t�H���g�l�́A3�b�ł��B
%
% ���Ƃ��΁A5�s5��̒P�ʍs���Excel�ɓ]�����܂��B
% 
%    rc = ddepoke(channel,'r1c1:r5c5',eye(5));
%
% �Q�l�FDDEINIT, DDETERM, DDEEXEC, DDEREQ, DDEADV, DDEUNADV.


%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.9.4.1 $  $Date: 2004/04/28 02:09:44 $
%   Built-in function.
