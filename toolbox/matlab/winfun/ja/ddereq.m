% DDEREQ �A�v���P�[�V��������̃f�[�^�̗v��
% 
% DDEREQ�́ADDE�ʐM�ɂ���ăT�[�o�A�v���P�[�V��������f�[�^��v�����܂��B
% DDEREQ�́A�v�����ꂽ�f�[�^���܂ލs����o�͂��邩�A���s�����Ȃ��s���
% �o�͂��܂��B
%
% data = DDEREQ(channel,item,format,timeout)
%
% data    �v�����ꂽ�f�[�^���܂ލs��B���s�̏ꍇ�́A��s��ɂȂ�܂��B
% channel DDEINIT����̒ʐM�`�����l��
% item    �v�����ꂽ�f�[�^�ɑ΂���T�[�o�A�v���P�[�V������DDE�A�C�e����
%         ���w�肷�镶����B
% format  (�I�v�V�����I��)�v�����ꂽ�f�[�^�̏������w�肷��2�v�f�̔z��B
%         1�Ԗڂ̗v�f�́A�g�p����Windows�N���b�v�{�[�h�̏������w�肵�܂��B
%         ���݂́ACF_TEXT�̂݃T�|�[�g����Ă��āA�l1�ɑΉ����܂��B2�Ԗ�
%         �̗v�f�́A���ʂ̍s��^�C�v���w�肷��z��ł��B�L���ȃ^�C�v�́A
%         NUMERIC(�f�t�H���g�ŁA�l0�ɑΉ�)�ƁASTRING(�l1�ɑ���)�ł��B�f
%         �t�H���g�t�H�[�}�b�g�́A[1 0]�ł��B
% timeout (�I�v�V�����I��)�I�y���[�V�����̐������Ԃ��w�肷��X�J���l�B��
%         �����Ԃ́A1000����1�b�P�ʂŎw�肵�܂��B�f�t�H���g�l�́A3�b�ł��B
%
% ���Ƃ��΁AExcel����A�Z���̍s���v�����܂��B
% 
%       mymtx = ddereq(channel, 'r1c1:r10c10');
%
% �Q�l�FDDEINIT, DDETERM, DDEEXEC, DDEPOKE, DDEADV, DDEUNADV.


%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.10.4.1 $  $Date: 2004/04/28 02:09:45 $
%   Built-in function.
