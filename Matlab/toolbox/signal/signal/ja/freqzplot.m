% FREQZPLOT �́A���g�������f�[�^���v���b�g���܂��B
% FREQZPLOT(H,W) �́A�x�N�g��W(���W�A��/�T���v��)�Őݒ肵�����g���Ōv�Z
% �������g���������v���b�g���܂��BH ���s��̏ꍇ�AFREQZPLOT �́AH �̗�
% �ɓK�p����A�e��P�ʂň�̎��g���������쐬���܂��B���g���x�N�g�� W
% �̒����́A�s�� H �̍s���Ɠ����ɂȂ�܂��B
%   
% FREQZPLOT(H,W,S) �́A��X�̃v���b�g�I�v�V�����ŕύX�\�ȕt���I�ȃv��
% �b�g��������w�肵�܂��BH, W, S �́A[H,W,S] = FREQZ(B,A,...) ���瓾
% ���܂��B
%
% S �́A���̃v���b�g����I�v�V���������\���̂ł��B
%
%   S.XUNITS: (������) - �v���b�g�p�̎��g��(x-��)�̒P��
%                        'rad/sample' (�f�t�H���g), 'Hz', 'kHz', 'MHz',
%                        'GHz', ���邢�́A���[�U�ݒ蕶����̂����ꂩ
%
%   S.YUNITS: (������) - �v���b�g�p�̃Q�C��(y-��)�̒P��
%                        'db' (�f�t�H���g), 'linear', 'squared'
%                        �̂����ꂩ
%
%   S.PLOT:   (������) - �v���b�g�^�C�v�B'both' (�f�t�H���g), 'mag',
%                        'phase' �̂����ꂩ
%
%   S.YPHASE: (������) - �ʑ��ɑ΂���y���̃X�P�[��
%                        'degrees'(�f�t�H���g)�A���邢�́A'radians'
%                        �̂����ꂩ
%
%   STR����q�̕�����I�v�V�����Ƃ��āAFREQZPLOT(H,W,STR)�́A
%   �v���b�g��1�̃I�v�V�������w�肷��A�ȒP�ȕ��@�ł��B
%   ���Ƃ��΁AFREQZPLOT(H,W,'mag')�́A�U���̂݃v���b�g���܂��B
%
% ���F
%      nfft = 512; Fs = 44.1; % Fs �́AkHz �P��
%      [b1,a1]  = cheby1(5,0.4,0.5);
%      [b2,a2]  = cheby1(5,0.5,0.5);
%      [h1,f,s] = freqz(b1,a1,nfft,Fs);
%      h2       = freqz(b2,a2,nfft,Fs);  % ���� nfft �� Fs ���g�p
%      h = [h1 h2];
%      s.plot   = 'mag';     % �Q�C���v���b�g�̂�
%      s.xunits = 'khz';     % ���g���̒P�ʂ̃��x����
%      s.yunits = 'squared'; % �Q�C���̓��̃v���b�g
%      freqzplot(h,f,s);     % 2�� Chebyshev �t�B���^�̉����̔�r
%
% �Q�l�FFREQZ, INVFREQZ, FREQS, GRPDELAY.



%   Copyright 1988-2002 The MathWorks, Inc.
