% RCOSINE �R�T�C�����[���I�t�t�B���^��݌v
%
% NUM = RCOSINE(Fd, Fs) �́A�f�B�W�^���]���W�{�����g�� Fd �ɂ��f�B�W
% �^���M�����t�B���^�����O���� FIR �R�T�C�����[���I�t�t�B���^��݌v���܂��B
% ���̃t�B���^�ɑ΂���W�{�����g���� Fs �ł��BFs �́AFd �����傫���A
% Fs/Fd �͐����łȂ���΂Ȃ�܂���B�f�t�H���g���[���I�t�t�@�N�^��0.5
% �ł��B�f�t�H���g�̒x�����Ԃ�3�ł��B���Ȃ킿�A�t�B���^�̒x���́A3/Fd �b
% �ƂȂ�܂��B
% 
% [NUM, DEN] = RCOSINE(Fd, Fs, TYPE_FLAG) �́A�t�B���^�̐݌v�@���w�����܂��B
% TYPE_FLAG �ɂ́A'iir'�A'sqrt'�A���邢�́A'iir/sqrt' �̂悤�ȑg�ݍ��킹
% �𓖂Ă邱�Ƃ��ł��܂��B���̂Ƃ��A�����̏����͏d�v�ł͂���܂���B
% 'fir'      FIR ���[���I�t�R�T�C���t�B���^�̐݌v�i�f�t�H���g�j
% 'iir'      FIR ���[���I�t�R�T�C���t�B���^�� IIR �ߎ���݌v
% 'normal'   �ʏ�̃R�T�C�����[���I�t�t�B���^�̐݌v�i�f�t�H���g�j
% 'sqrt'     ���[�g�R�T�C�����[���I�t�t�B���^�̐݌v
% 'default'  �f�t�H���g�̎g�p(FIR, Normal�R�T�C�����[���I�t�t�B���^)
% 
% [NUM, DEN] = RCOSINE(Fd, Fs, TYPE_FLAG,  R) �́A���[���I�t�t�@�N�^ R 
% ��ݒ肵�܂��BR �͔͈� [0, 1] �̎����ł��B
% 
% [NUM, DEN] = RCOSINE(Fd, Fs, TYPE_FLAG, R, DELAY) �́A�t�B���^�̒x�� 
% DELAY ��ݒ肵�܂��BDELAY �͐��̐����łȂ���΂Ȃ�܂���BDelay/Fd �́A
% �b�P�ʂł̃t�B���^�̒x���ł��B
% 
% [NUM, DEN] = RCOSINE(Fd, Fs, TYPE_FLAG, R, DELAY, Tol) �́AIIR �t�B���^
% �݌v�ɋ��e�l TOL ��ݒ肵�܂��BTOL �̃f�t�H���g�l��0.01�ł��B
% 
% ��]����t�B���^�� FIR �t�B���^�ł���ꍇ�ADEN �̏o�͂�1�ɂȂ�܂��B
% 
% �Q�l�F RCOSFLT, RCOSIIR, RCOSFIR, RCOSDEMO.


%   Copyright 1996-2002 The MathWorks, Inc.
%   $Revision: 1.6.4.1 $
