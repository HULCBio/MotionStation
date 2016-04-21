% RCOSIIR   �R�T�C�����[���I�t IIR �t�B���^��݌v���܂��B
%
% [NUM, DEN] = RCOSIIR(R, T_DELAY, RATE, T, TOL) �́A�ݒ肵�����[���I�t
% �t�@�N�^ R ������ FIR �R�T�C�����[���I�t�t�B���^�ɋߎ����� IIR �R�T�C��
% ���[���I�t�t�B���^��݌v���܂��BT_DELAY �́AT �̐����{�̒x���ݒ肵�܂��B
% RATE �́A�e��� T �̒��ł̕W�{���ł��邩�A�܂��́A�t�B���^�̕W�{��
% ���[�g�� T/RATE �𖞑����邩�̂ǂ��炩�Œ�`����܂��B�f�t�H���g�l��
% RATE ��5�AT �̓V���{���Ԋu�ł��BIIR �t�B���^�̎����́ATOL ��1���傫��
% �����̏ꍇ�ATOL �Ō��肳��܂��BTOL ��1��菬�����ꍇ�A����́A������
% �I���ł� SVD �v�Z�̑��΋��e�덷�ƍl�����܂��BTOL �̃f�t�H���g�l�́A
% 0.01 �ł��B�R�T�C�����[���I�t�t�B���^�̎��ԉ����́A���̌^������
% ���܂��B
%
%       h(t) = sinc(t/T) cos(pi R t/T)/(1 - 4 R^2 t^2 /T^2)
%
% ���g���̈�ł́A���̃X�y�N�g�������Ă��܂��B
%
%         / T                                 0 < |f| < (1-r)/2/T �̂Ƃ�
%         |         pi T         1-R    T     1-R         1+R
% H(f) = < (1 + cos(----) (|f| - ----) ---    --- < |f| < --- �̂Ƃ�
%         |           r           2T    2     2 T         2 T
%         \ 0                                 |f| > (1+r)/2/T �̂Ƃ�
%     
% [NUM, DEN] = RCOSIIR(R, T_DELAY, RATE, T, TOL, FILTER_TYPE) �́A
% FILTER_TYPE == 'sqrt' �̏ꍇ�A������ FIR ���[�g�R�T�C�����[���I�t
% �t�B���^�� IIR �ߎ���݌v���܂��B
%     
% RCOSIIR(...) �́A�R�T�C�����[���I�t�t�B���^�̎��ԉ����Ǝ��g��������
% �v���b�g���܂��B
%     
% RCOSIIR(..., COLOR) �́A�����ϐ� COLOR �Őݒ肵���J���[���g���āA����
% �����Ǝ��g���������v���b�g���܂��BCOLOR �̒��̕�����́APLOT �Őݒ�
% �ł���^�C�v�̂��̂ł��B
%     
% [NUM, DEN, SAMPLE_TIME] = RCOSIIR(...) �́AIIR �t�B���^�ƃt�B���^��
% �W�{���Ԃ��o�͂��܂��B
% 
% �Q�l�F RCOSFIR, RCOSFLT, RCOSINE, RCOSDEMO.


%   Copyright 1996-2002 The MathWorks, Inc.
%   $Revision: 1.6.4.1 $
