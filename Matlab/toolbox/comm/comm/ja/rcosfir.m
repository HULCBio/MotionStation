% RCOSFIR   �R�T�C�����[���I�t FIR �t�B���^��݌v
%
% B = RCOSFIR(R, N_T, RATE, T) �́A�R�T�C�����[���I�t FIR �t�B���^��
% �݌v���A�o�͂��܂��B�R�T�C�����[���I�t�t�B���^�́A�ϒ�/���M�̌�A
% ���l�Ɏ�M/�����̑O�ŁA�V���{���X�g���[���̐��`��I�[�o�[�T���v�����O�ɁA
% �T�^�I�Ɏg���܂��B�����Ԋ����N�������ɁA�I�[�o�[�T���v�����ꂽ
% �V���{���X�g���[���̑ш敝���������邽�߂Ɏg���܂��B
%
% �R�T�C�����[���I�t�t�B���^�̎��ԉ����́A���̂悤�ɂȂ�܂��B
%
%     h(t) = SINC(t/T) COS(pi R t/T)/(1 - 4 R^2 t^2 /T^2)
%
% ���g���̈�ł́A���̃X�y�N�g���������܂��B
%
%        /  T                                  0 < |f| < (1-r)/2/T �̂Ƃ�
%        |          pi T         1-R    T      1-R         1+R
% H(f) = < (1 + cos(----) (|f| - ----) ---     --- < |f| < --- �̂Ƃ�
%        |            r           2T    2      2 T         2 T
%        \  0                                  |f| > (1+r)/2/T �̂Ƃ�
%     
%
% T �́A���͐M���̕W�{�������ŁA�P�ʂ͕b�ł��BRATE �́A�t�B���^�ɑ΂���
% �I�[�o�T���v�����O���[�g�ł�(�܂��́A���̓T���v�����̏o�̓T���v����)�B
% ���[���I�t�t�@�N�^ R �́A�J�ڑт̕������肵�܂��BR �͖������ł��B
% �J�ڑт́A(1-R)/(2*T) < |f| < (1+R)/(2*T) �ł��B
%
% N_T �́A�X�J���A�܂��́A����2�̃x�N�g���ł��BN_T ���X�J���̏ꍇ�A
% �t�B���^���� 2 * N_T + 1 ���̓T���v���ɂȂ�܂��BN_T ���x�N�g���̏ꍇ�A
% �t�B���^�̕������肵�܂��B���̏ꍇ�A�t�B���^���� N_T(2) - N_T(1) + 1 
% ���̓T���v��(�܂��́A(N_T(2) - N_T(1))* RATE + 1 �o�̓T���v��)�ł��B 
%
% N_T �̃f�t�H���g�l��3�ł��BRATE �̃f�t�H���g�l��5�ł��BT �̃f�t�H���g
% �l��1�ł��B  
%
% B = RCOSFIR(R, N_T, RATE, T, FILTER_TYPE) �́AFILTER_TYPE == 'sqrt' ��
% �ꍇ�A���[�g�R�T�C�����[���I�t�t�B���^��݌v���A�o�͂��܂��B
% FILTER_TYPE �̃f�t�H���g�l�A'normal' �́A�t�����[���I�t�t�B���^���o��
% ���܂��B
%
% RCOSFIR(R, N_T, RATE, T, FILTER_TYPE, COL) �́A�����ϐ� COL �Őݒ肵��
% ���C���̃J���[�������ԉ����Ǝ��g���������쐬���܂��BCOL �̒��̕�����
% �́APLOT �Œ�`����悤�ȃ^�C�v��ݒ肷�邱�Ƃ��ł��܂��BCOL ������
% ���Ȃ��ꍇ�A�f�t�H���g�J���[���v���b�g�Ɏg���܂��B
%
% [B, Sample_Time] = RCOSFIR(...) �́AFIR �t�B���^�ƁA�t�B���^�ɑ΂���o
% �͕W�{���Ԃ��o�͂��܂��B�t�B���^�̕W�{���Ԃ́AT / RATE �ł��邱�Ƃɒ�
% �ӂ��Ă��������B
%
% �Q�l�F RCOSIIR, RCOSFLT, RCOSINE, FIRRCOS, RCOSDEMO.


%   Copyright 1996-2002 The MathWorks, Inc.
%   $Revision: 1.6.4.1 $
