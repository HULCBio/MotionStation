% TH2FF  ���f���̎��g���֐��Ƃ��̕W���΍�
% 
%   G = TH2FF(TH) �܂��́A[G, NSP] = TH2FF(TH)
%
%   TH: THETA �s��ŋL�q���ꂽ���f��(THETA �Q��)
%
% G �͓`�B�֐�����ŁANSP ��(�w�肳��Ă���ꍇ)�A���f�� TH �ɑ΂���G��
% �X�y�N�g���ł��B�����̍s��́ATH �̋����U�s�񂩂琄�肳�ꂽ�W���΍�
% ���܂ށA�W���̎��g���֐��`���ł�(FREQFUNC �Q��)�B
%
% TH �����n��̏ꍇ�AG �͂��̃X�y�N�g���ƂȂ�܂��B���U���ԃ��f�����A��
% ���ԃ��f���ɂ��Ή����܂��B
%
% ���f�� TH �������̓��͂����ꍇ�AG �́AG = TH2FF(TH,[j1 j2 ... jk]) 
% �őI�����ꂽ���͔ԍ� j1 j2 ... jk �̓`�B�֐��ƂȂ�܂�(�f�t�H���g�́A
% ���ׂĂ̓��͂ł�)�B0���� pi/T �܂ł͈̔͂�128�_�̓��Ԋu���g���Ōv�Z��
% ��܂��B�����ŁAT �� TH �Ŏw�肳�ꂽ�T���v�����O�����ł��B�C�ӂ̎��g��
%  w (�Ⴆ�� LOGSPACE �Ő������ꂽ�s�x�N�g��)�Ōv�Z�������ꍇ�AG = TH2FF
% (TH, ku, w)�Ǝ��s���܂��B�`�B�֐��́ABODEPLOT�Ńv���b�g�ł��܂��B
%
% ���f�� TH �������̏o�͂����ꍇ�AG �́AG = TH2FF(TH, ku, w, ky)�őI��
% ���ꂽ�o�� ky (�s�x�N�g��)�̎��g���֐��ƂȂ�܂�(�f�t�H���g�͂��ׂĂ�
% �o�͂ł�)�B
%
% �Q�l:    BODEPLOT, FFPLOT, FREQFUNC, NYPLOT, TRF

%   Copyright 1986-2001 The MathWorks, Inc.
