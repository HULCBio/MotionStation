% WAVRECORD Windows �I�[�f�B�I���̓f�o�C�X���g���āA������^��
%
% WAVRECORD(N,FS,CH) �́AWindows WAVE �I�[�f�B�I�f�o�C�X���g���āA����
% �`���l�� CH ����AFS Hz �̃T���v�����O���[�g�ŁAN �̃I�[�f�B�I
% �T���v����^�����܂��B�W���̃I�[�f�B�I���[�g�́A8000, 11025, 22050, 
% 44100 Hz �ł��BCH �́A1�A�܂��� 2(���m�������X�e���I)�ł��B�ݒ肵��
% ����΁AFS = 11025 Hz�ŁACH = 1 �ł��B
%
% WAVRECORD(..., DTYPE) �́ADTYPE �Őݒ肵���f�[�^�^�C�v���g���āA�f�[�^
% ��^�����āA�o�͂��܂��B�T�|�[�g���Ă���f�[�^�^�C�v�ƑΉ�����r�b�g��
% �����Ɏ����܂��B
%        DTYPE     �r�b�g��/�T���v��
%       'double'      16
%       'single'      16
%       'int16'       16
%       'uint8'        8
%
% ���̊֐��́A32-bit  Windows �}�V���ł̂ݎg�p�ł��܂��B
%
% ���: 11.025 Hz�ŃT���v�����O����16�r�b�g�̃I�[�f�B�I�f�[�^5�b����^�����āA
%         �Đ����܂��傤�B
%       Fs = 11025;
%       y  = wavrecord(5*Fs, Fs, 'int16');
%       wavplay(y, Fs);
%
%   �Q�l �F WAVPLAY, WAVREAD, WAVWRITE.


%   Author: D. Orofino
%   Copyright 1988-2004 The MathWorks, Inc. 
