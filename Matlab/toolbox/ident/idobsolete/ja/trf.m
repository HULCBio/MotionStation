% TRF   ���f���̎��g���֐�
%
%   G = trf(TH) �܂��́A
%   [G, NSP] = trf(TH)
%
% TH : THETA�s ��Œ�`���ꂽ���f��(THETA�Q��)
% 
% G �́A�`�B�֐�����ŁANSP ��(�w�肳�ꂽ�ꍇ)�A���f��TH�ɑ΂���G���X�y
% �N�g���ł��B�����̍s��́ATH �̋����U�s�񂩂狁�߂�ꂽ����W���΍�
% ���܂ޕW���I�Ȏ��g���֐��t�H�[�}�b�g�ł�(FREQFUNC �Q��)�BTH �����n���
% �ꍇ�AG �͂��̃X�y�N�g���ł��B
%
% ���f��TH���������͂����ꍇ�AG �́AG = trf(TH, [j1 j2 ... jk])�őI��
% ���ꂽ���͔ԍ� j1 j2 ... jk �̓`�B�֐��ł�(�f�t�H���g�́A���ׂĂ̓���
% �ł�)�B0���� pi/T �̋�Ԃ�128�_�̓��Ԋu���g���Ōv�Z����܂��B�����ŁA
% T �� TH �Ŏw�肳�ꂽ�T���v�����O���g���ł��B�C�ӂ̎��g�� w[rad/s](����
% ���΁ALOGSPACE �Ő������ꂽ�s�x�N�g��)�Ōv�Z���邽�߂ɂ́AG = trf(TH, 
% ku, w)�Ǝ��s���܂��B�`�B�֐��́ABODEPLOT �ŕ\���ł��܂��BBODEPLOT(trf
% (TH))�Ǝ��s���܂��B
%
% ���f�� TH �������o�͂����ꍇ�AG �́AG = trf(TH, ku, w, ky)�őI������
% ���o�� ky(�s�x�N�g��)�̓`�B�֐��ł�(�f�t�H���g�́A���ׂĂ̏o�͂ł�)�B
%
% �Q�l:    TH2FF

%   Copyright 1986-2001 The MathWorks, Inc.
