% MODULATE  �ʐM�V�~�����[�V�����̂��߂̐M���̕ϒ�
%
% Y = MODULATE(X,Fc,Fs,METHOD,OPT) �́A���� METHOD �̃I�v�V�����ł���
% �ϒ����@�����ꂩ1���g���āA�����g���g��Fc�ƃT���v�����O���g��Fs����
% ���b�Z�[�W�M�� X ��ϒ����܂��BMETHOD �̐ݒ�Ɉ˂�A�I�v�V���� OPT 
% ��K�v�Ƃ�����̂�����܂��BOPT �́A�I������ϒ������Ɉˑ����A�ꍇ��
% ����Ă͗]���ȃp�����[�^�ł��B
%
%  METHOD              �@�@�@�ϒ����@
%
% 'am'       �U���ϒ��A�����g�сA�}�������g�B
%
% 'amdsb-sc' OPT �͐ݒ�ł��܂���B
%
% 'amdsb-tc' �U���ϒ��A�����g�сA�`�������g�B
% 
%            OPT�́A�����R�T�C���g���悶��O��X���猸�Z����X�J���l
%            �ł��B�f�t�H���g�́Amin(min(x)) �ł��B����ŁA�I�t�Z�b�g
%            ���b�Z�[�W�M�����A���ŁA���A�ŏ��l���[���ɂȂ�܂��B
% 
% 'amssb'    �U���ϒ��A�Б��g�сBOPT �͐ݒ�ł��܂���B
%
% 'fm'       ���g���ϒ��B
%            OPT�́A���g���ϒ��̒萔 kf ���w�肷��X�J���l�ł��BFc Hz��
%            �ő���g���ɑ΂���f�t�H���g�l�́A kf = (Fc/Fs)*2*pi/max
%            (max(abs(X)))�@�ɂȂ�܂��B
%
% 'pm'       �ʑ��ϒ��B
%            OPT�́A�ʑ��ϒ��̒萔 kp ���w�肷��X�J���l�ł��B�ő�ʑ�
%            �}�΃��W�A���ɑ΂���f�t�H���g�l�́A  kf = pi/max(max(abs
%            (x))) �ɂȂ�܂��B
%
% 'pwm'      �p���X���ϒ��B
%            OPT�� 'centered'�ɐݒ肷��ƁA���[�ɗ����オ���Ă���p���X
%            �͊e���������̒��S�ɐݒ肳��܂��B�@
%
% 'ppm'      �p���X�ʒu�ϒ��B
%            OPT�́A0����1�̊ԂŁA�����g�̎�����P�ʂɕ������ꂽ�e�X��
%            �p���X�̕����w�肵�Ă��܂��BOPT�̃f�t�H���g�l��0.1�ł��B
%
% 'qam'      ����U���ϒ��BOPT�́AX�𒼌�U���ϒ��������̂Ɠ����T�C�Y��
%            �s��ł��B
%
% X���z��̏ꍇ�AMODULATE�́A�e���ϒ����܂��B
%
% [Y,T] = MODULATE(...)�́AY�Ɠ��������̎��ԃx�N�g�����o�͂��܂��B
%
% �Q�l�F   DEMOD, VCO ( Signal Processing Toolbx ), 
%          DMOD ( Communications Toolbox ).



%   Copyright 1988-2002 The MathWorks, Inc.
