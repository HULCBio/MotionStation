% WAVWRITE   Microsoft WAVE (".wav")�T�E���h�t�@�C���ւ̏����o��
%
% WAVWRITE(Y,FS,NBITS,WAVEFILE) �́A�f�[�^Y���A�t�@�C����WAVEFILE�Ŏw�肳
% �ꂽWindows WAVE �t�@�C���ɁA�T���v�����[�gFS�A�r�b�g��NBITS�ŏ����o��
% �܂��BNBITS�́A8, 16, 24, 32�r�b�g�łȂ���΂Ȃ�܂���BStereo �f�[�^�́A
% 2��̍s��Ŏw�肵�Ă��������BNBITS < 32 �ɑ΂��ẮA�͈� [-1,+1] �ȊO��
% �U���l�͐؂����܂��B
%
% WAVWRITE(Y,FS,WAVEFILE) �́ANBITS = 16�r�b�g�����肵�Ă��܂��B
% WAVWRITE(Y,WAVEFILE) �́ANBITS = 16�r�b�g�AFS = 8000Hz�����肵�Ă��܂��B.
%
% 8�A16�A24�r�b�g�t�@�C���́A�^�C�v1 ����PCM�ł��B32�r�b�g�t�@�C���́A
% �^�C�v3���K�����������_���Ƃ��ď�����Ă��܂��B
%
% �Q�l �F WAVREAD, AUWRITE.


%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.1.6.2 $  $Date: 2004/04/28 01:45:19 $
