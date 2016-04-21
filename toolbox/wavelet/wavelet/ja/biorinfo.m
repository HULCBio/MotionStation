% BIORINFO �@�o�����X�v���C���E�F�[�u���b�g�Ɋւ�����
%
% �o�����E�F�[�u���b�g
%
% ��ʓI����: 
% FIR �t�B���^�ɂ��Ώ̐��������ȈӖ��ł̍č\�����\�ȃR���p�N�g
% �T�|�[�g���ꂽ�X�v���C���E�F�[�u���b�g�ł�(Haar �ȊO�̒����̏ꍇ�́A
% �č\���ł��܂���)�B
%
%    �t�@�~���@              Biorthogonal
%    ����                    bior
%    ����  Nr,Nd             Nr = 1 �ANd = 1�A3�A5
%    �č\���Ɋւ��� r        Nr = 2 �ANd = 2�A4�A6�A8
%    �����Ɋւ��� d          Nr = 3 �ANd = 1�A3�A5�A7�A9
%                            Nr = 4 �ANd = 4
%                            Nr = 5 �ANd = 5
%                            Nr = 6 �ANd = 8
%
% ���                    bior3.1�Abior5.5
%
%    ����                  �Ȃ�
%    �o���� �@             ����
%    �R���p�N�g�T�|�[�g      ����
%    ���U�E�F�[�u���b�g�ϊ��@��
%    �A���E�F�[�u���b�g�ϊ�  ��
%
%    �T�|�[�g��     �@�@     �č\���ɑ΂��āA2Nr+1 �F�����ɑ΂��āA2Nd+1
%    �t�B���^�̒���        max(2Nr,2Nd)+2 �ł����A�����I�Ȃ���
%    bior Nr.Nd              ld                      lr    
%                         LoF_D �̗L����          HiF_D �̗L����
%
%    bior 1.1                 2                       2  
%    bior 1.3                 5                       2
%    bior 1.5                10                       2
%    bior 2.2                 5                       3
%    bior 2.4                 9                       3
%    bior 2.6                13                       3
%    bior 2.8                17                       3
%    bior 3.1                 4                       4
%    bior 3.3                 8                       4
%    bior 3.5                11                       4
%    bior 3.7                16                       4
%    bior 3.9                20                       4
%    bior 4.4                 8                       7
%    bior 5.5                 9                      11
%    bior 6.8                17                      11
%
%    psi rec �ɑ΂���
%    ���M�������e�B              �ߓ_�ŁANr-1 �� Nr-2 
%    �Ώ̐�                      ����  
%    psi dec �ɑ΂��郂�[�����g�@Nr
%
% ����: 
% bior 4.4 �A5.5 �y�� 6.8 �́A�݂��ɍč\���A�����֐��y�уt�B���^��
% �ߎ����Ă��܂� �B          
%
% �Q�l����: I. Daubechies, 
%           Ten lectures on wavelets, 
%           CBMS, SIAM, 61, 1994, 271-280.
%
% �t�o�����X�v���C���E�F�[�u���b�g�Ɋւ�������Q�Ƃ��Ă��������B


%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 12-Mar-96.
%   Copyright 1995-2002 The MathWorks, Inc.
