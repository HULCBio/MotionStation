% DDEEXEC ���s�̂��߂̕������]��
% 
% DDEEXEC�́A�m�����ꂽDDE�ʐM�ɂ���āA���̃A�v���P�[�V�����Ɏ��s����
% ���߂̕������]�����܂��B������́A����command�Ƃ��Ďw�肵�܂��B
%
% rc = DDEEXEC(channel,command,item,timeout)
%
% rc      �Ԃ�l: 0�͎��s�A1�͐������Ӗ����܂��B
% channel DDEINIT����̒ʐM�`�����l��
% command ���s�����R�}���h���w�肷�镶����
% item    (�I�v�V�����I��)���s�̂��߂�DDE�A�C�e�����w�肷�镶����B����
%         �����́A�����̃A�v���P�[�V�����ł͎g�p����܂���B�A�v���P�[
%         �V�����ł��̈������K�v�ȏꍇ�Acommand�ɂ��Ă̒ǉ�����^��
%         �܂��B�ڍׂ́A�T�[�o�h�L�������g���Q�Ƃ��Ă��������B
% timeout (�I�v�V�����I��)�I�y���[�V�����̐������Ԃ��w�肷��X�J���l�B
%         timeout�́A1000����1�b�P�ʂŎw�肵�܂��Btimeout�̃f�t�H���g�l
%         �́A3�b�ł��B
%
% ���Ƃ��΁A�ʐM�Ɋ��蓖�Ă�ꂽ�`�����l����^���A�R�}���h��Excel�ɓ]��
% ���܂��B
% 
%    rc = ddeexec(channel�A'[formula.goto("r1c1")]');
% 
% �Q�l�FDDEINIT, DDETERM, DDEREQ, DDEPOKE, DDEADV, DDEUNADV.


%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.9.4.1 $  $Date: 2004/04/28 02:09:42 $
%   Built-in function.
