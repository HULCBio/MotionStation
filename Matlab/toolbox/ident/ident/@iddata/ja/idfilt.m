% IDDATA/IDFILT �́A�f�[�^���t�B���^�����O���܂��B
% ZF = IDFILT(Z,N,Wn)�A�܂��́AZF = IDFILT(Z,FILTER)
%
%   Z  : �o���̓f�[�^�AIDDATA �I�u�W�F�N�g 
%   ZF : �t�B���^��K�p����f�[�^�BZ �� IDDATA �̏ꍇ�AZF �ł��B
%        ���̏ꍇ�AZF �̗�́AZ �̗�ɑΉ����܂��B
%   N  : �g�p����t�B���^�̎���
%   Wn : �J�b�g�I�t���g�����ANyquist���g�����x�[�X�ɕ\����������
%        Wn ���X�J���̏ꍇ�A���[�p�X�t�B���^���g�p
%        Wn = [Wl Wh] �̏ꍇ�A�o���h�p�X�t�B���^���g�p�B
%
% ZF = IDFILT(Z,N,Wn,'high')�A�܂��́AZF = IDFILT(Z,N,[Wl Wh],'stop') ��
% �g���āA�n�C�p�X�܂��̓o���h�X�g�b�v�t�B���^���g�p���邱�Ƃ��ł��܂��B
%
% [ZF,THFILT] = IDFILT(Z,N,Wn) �́AIDMODEL �Ƃ��ăt�B���^���o�͂��܂��B
% 
% �Q�l�F IDDATA/DETREND, IDDATA/RESAMPLE

%   L. Ljung 10-1-89, 3-3-95.
%   The code is adopted from several routines in the Signal Processing
%   Toolbox.


% $Revision: 1.4 $
% Copyright 1986-2001 The MathWorks, Inc.
