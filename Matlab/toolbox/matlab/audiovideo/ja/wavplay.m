% WAVPLAY �́AWindows �̃I�[�f�B�I�o�̓f�o�C�X���g���āA�����Đ����܂��B
% 
% WAVPLAY(Y,FS) �́A�T���v�����g�� FS Hz �����x�N�g�� Y �̐M�����AWi-
% ndows WAVE �I�[�f�B�I�f�o�C�X�ɑ���܂��B�W���I�ȃI�[�f�B�I�̃T���v��
% ���g���́A8000,11025,22050,44100 Hz �ł��B
% WAVPLAY(Y) �́A�����I�ɃT���v�����[�g�� 11025 Hz �ɐݒ肵�܂��B�X�e��
% �I�ł̍Đ��p�ɁAY �́AN �s2��̍s��ł��B
% 
% WAVPLAY(...,'async') �́A�����̍Đ����n�߂܂��B�����āA�֐��R�[���ɖ�
% ��܂�(���Ȃ킿�A�m���u���b�L���O�R�[��)�B
% WAVPLAY(...,'sync') �́A�����̍Đ����I������܂ŁA�֐��R�[������߂��
% ����(���Ȃ킿�A�u���b�L���O�R�[��)�B���ꂪ�A�f�t�H���g�̍Đ����[�h�ł��B
%
% Y �́Adouble,int16,uint8 �s��̂����ꂩ�ŃX�g�A�����I�[�f�B�I�T���v��
% �łȂ���΂Ȃ�܂���B�{���x�f�[�^�T���v���́A-1.0 <= y <= 1.0 �͈̔�
% �̒l�ɂȂ�܂��B���͈̔͊O�̒l�́A��荞�݂܂���B
%
% Y �ɑ΂��ăT�|�[�g���Ă���f�[�^�^�C�v��Đ��Ŏg�p�ł���r�b�g�����A
% ���ɂ܂Ƃ߂Ď����܂��B
% 
%      �f�[�^�^�C�v   �r�b�g/�T���v��
%       'double'      �@�@16
%       'single'      �@�@16
%       'int16'       �@�@16
%       'uint8'        �@�@8
%
% ���̊֐��́A32-bit Windows �}�V���݂̂Ŏg�p�ł��܂��B
%
% �Q�l�FSOUND, SOUNDSC.


%   Author: D. Orofino
%   Copyright 1984-2002 The MathWorks, Inc.
%   $Revision: 1.14 $  $Date: 2002/04/24 17:49:28 $

