% INTERP �����t�@�N�^�ɂ��T���v�����O���[�g�̑���(���)
%
% Y = INTERP(X,R)�́A�x�N�g�� X �̃T���v�����O���[�g��R�{��������������
% ���B��Ԃ��ꂽ�x�N�g��Y�́A�I���W�i���̓���X���R�{�����Ȃ�܂��FLEN-
% GTH(Y) = R*LENGTH(X)�B
%
% �I���W�i���f�[�^��ω������Ȃ��ŁA���}�����_�Ƃ��̗��z�I�ȓ_�Ƃ̊Ԃ̕�
% �ϓ��덷���ŏ��ɂȂ�悤�ȓ��ʂȑΏ�FIR�t�B���^B��݌v���܂��B
%
% Y = INTERP(X,R,L,ALPHA)�́A����L(�t�B���^�̒���)��ALPHA(�J�b�g�I�t���g
% ��)��ݒ肵�܂��BL�̃f�t�H���g�l��4�ŁAALPHA�̃f�t�H���g�l��0.5�ł��B
% ��ԂɎg�p�����I���W�i���T���v���l�̐��́A2*L�ł��B�ʏ�AL��10�ȉ���
% ���Ă��������B�܂��A�t�B���^�̒����́A2*L*R+1�ł��B�I���W�i���̐M���́A
% ���K���J�b�g�I�t���g��(0 < ALPHA < =  1.0)�Ő������ꂽ�ш���ɂ������
% �Ɖ��肵�Ă��܂��B
%
% [Y,B] = INTERP(X,R,L,ALPHA)�́A��ԂɎg�p���ꂽ�t�B���^�W���x�N�g��B��
% �o�͂��܂��B
%
% �Q�l�F   DECIMATE, RESAMPLE, UPFIRDN.



%   Copyright 1988-2002 The MathWorks, Inc.
