% IDDATA/IDFILT   �f�[�^�̃t�B���^�����O
% 
% ZF = IDFILT(Z,N,Wn)�A�܂��́AZF = IDFILT(Z,FILTER)
%
%   Z      : �o�� - ���̓f�[�^�ŁA�s��A�܂��́AIDDATA �I�u�W�F�N�g�̌^
%            �����Ă��܂��B 
%   ZF     : �t�B���^�����O���ꂽ�f�[�^�BZ ���AIDDATA �̏ꍇ�AZF ��IDD-
%             ATA �ɂȂ�܂��B���̑��̏ꍇ�AZF �̗�́AZ �̗�ɑΉ�����
%             ���B
%   FILTER : SISO ���`�V�X�e���ŁALTI�A�܂��́AIDMODEL �I�u�W�F�N�g�A��
%            ���́A�Z���z��{a,b,c,d}(��ԋ�ԍs��)�A�܂��́A{num,den}(��
%            �q�ƕ���)�̂����ꂩ�Őݒ肵�����̂ł��B
%   N      : �g�p����t�B���^�̎����ŁA�t�B���^�́A�W���I�� Butterworth 
%            �t�B���^�ł��B
%   Wn     : Nyquist ���g����1�Ƃ��āA���K�������J�b�g�I�t���g��
%            Wn ���X�J���̏ꍇ�A���[�p�X�t�B���^���g���܂��B
%            Wn = [Wl Wh] �̏ꍇ�A�ʉߑш� Wn �����o���h�p�X�t�B���^��
%            �g���܂��B
%
% ZF = IDFILT(Z,N,Wn,'high')�A�܂��́AZF = IDFILT(Z,N,[Wl Wh],'stop') ��
% �g���āA�n�C�p�X�t�B���^��A�o���h�X�g�b�v�t�B���^���g�����Ƃ��ł��܂��B
%
% �Ō�̈��� 'causal'/'noncausal' �̓t�B���^�����O�̃��[�h�����肵�܂�:
% ZF = IDFILT(Z,...,'Causal') �́A�f�[�^�ɑ΂��āA���ʐ���ۂ����t�B���^
% �����O�����A����AZF = IDFILT(Z,...,'Noncausal') �́A�[���ʑ��̔����
% ���̃t�B���^�����O���s���܂��B
%
% [ZF,MFILT] = IDFILT(Z,N,Wn) ���g���āA�t�B���^�́A��� IDMODEL �Ƃ�
% �ďo�͂���܂��B
%
% �Q�l�F IDDATA/DETREND �� IDDATA/RESAMPLE


%   L. Ljung 10-1-89, 3-3-95.
%   The code is adopted from several routines in the Signal Processing
%   Toolbox.
%   Copyright 1986-2001 The MathWorks, Inc.
