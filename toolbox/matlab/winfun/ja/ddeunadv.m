% DDEUNADV �A�h�o�C�U�������N�̉���
% 
% DDEUNADV�́ADDEADV�ɂ���Ċm�����ꂽMATLAB�ƃT�[�o�A�v���P�[�V����
% �Ԃ̃A�h�o�C�U�������N���������܂��Bchannel,item,format�́A�����N��
% ����������DDEADV�Ŏw�肳�ꂽ���̂Ɠ����łȂ���΂Ȃ�܂���Btimeout
% �������w�肵�āAformat�����̓f�t�H���g�l��p����ꍇ�́Aformat������
% ��s��Ƃ��Ďw�肵�Ȃ���΂Ȃ�܂���B
%
% rc = DDEUNADV(channel,item,format,timeout)
%
% rc      �Ԃ�l: 0�͎��s�A1�͐������Ӗ����܂��B
% channel DDEINIT����̒ʐM�`�����l���B
% item    �A�h�o�C�U�������N�ɑ΂���DDE�A�C�e�������w�肷�镶����B
% format  (�I�v�V�����I��)�A�h�o�C�U�������N�̂��߂̃f�[�^�`�����w�肷��
%         2�v�f�̔z��B�A�h�o�C�U�������N��ݒ肷�邽�߂̊֐�DDEADV��
%         format�������w�肵���ꍇ�ADDEUNADV�ł������l���w�肵�Ȃ����
%         �Ȃ�܂���B�z��̌`���́ADDEADV���Q�Ƃ̂��ƁB
% timeout (�I�v�V�����I��)�I�y���[�V�����̐������Ԃ��w�肷��X�J���l�B��
%         �����Ԃ́A1000����1�b�P�ʂŎw�肵�܂��B�f�t�H���g�l�́A3�b�ł��B
%
% ���Ƃ��΁Addeadv�̗��Ŋm�������z�b�g�����N���������܂��B
% 
%    rc = ddeunadv(channel, 'r1c1:r5c5');
% 
% format�̓f�t�H���g�l�Atimeout�͒l���w�肵�āA�z�b�g�����N���������܂��B
% rc = ddeunadv(chan, 'r1c1:r5c5',[],6000);
%
% �Q�l �F DDEINIT, DDETERM, DDEEXEC, DDEREQ, DDEPOKE, DDEADV.


%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.10.4.1 $  $Date: 2004/04/28 02:09:47 $
%   Built-in function.
