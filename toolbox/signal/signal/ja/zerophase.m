% ZEROPHASE ���ۂ̃t�B���^�̗�_-�ʑ��������o�͂��܂��B
% [Hr,W] = ZEROPHASE(B,A)�́A��_-�ʑ�����Hr�ƁAHr���v�Z�����
% ���g���x�N�g��W ��(rad/sample��)�o�͂��܂��B
% ��_-�ʑ������́A�P�ʉ~�̏㔼���ɓ��Ԋu�ɕ��� 512�_�ŕ]������܂��B 
%
% ��_-�ʑ�����Hr(w)�́A���g������H(w)�Ƃ��̊֌W������܂��B
%                                       jPhiz(w)
%                          H(w) = Hr(w)e
%
% ��_-�ʑ������́A��Ɏ����ł����A��Βl�ł̉����Ƃ͓����ł͂Ȃ�
% ���Ƃɒ��ӂ��Ă��������B���ɁA�O�҂́A���ɂȂ邱�Ƃ��ł��܂����A
% ��҂́A���ɂȂ邱�Ƃ͂���܂���B
%
% [Hr,W] = ZEROPHASE(B,A, NFFT)�́A��_-�ʑ��������v�Z����ꍇ�A�P�ʉ~��
% �㔼�~����NFFT���g���_���g�p���܂��B
%
% [Hr,W] = ZEROPHASE(B,A,NFFT,'whole') �́A�P�ʉ~�̑S����NFFT���g���̓_
% ���g�p���܂��B
%
% [Hr,W] = ZEROPHASE(B,A,W) �́A�x�N�g��W�Ŏ������
% radians/sample (�ʏ�A0 �ƃ΂̊�)�́A���g���ł̗�_�]�ʑ�����
% ���o�͂��܂��B
%
% [Hr,F] = ZEROPHASE(...,Fs) �́AHz�ŕ\�����T���v�����O���g�����g�p���āA
% Hr ���v�Z�����A���g���x�N�g��F (Hz�ŕ\��)�����肵�܂��B
%
% [Hr,W,Phi] = ZEROPHASE(...) �́A�A���ʑ�Phi���o�͂��܂��B
% ���̗ʂ́A��_�]�ʑ����������ł���ꍇ�A�t�B���^�̈ʑ������ɓ����ł�
% ����܂���B
%
% ZEROPHASE(...)���A�o�͈����������Ȃ��ꍇ�A��_- �ʑ����������g���ɑ΂���
% �v���b�g���܂��B 
%
% ��� #1:
%     b=fircls1(54,.3,.02,.008);
%     zerophase(b)
%
% ��� #2:
%     [b,a] = ellip(10,.5,20,.4);
%     zerophase(b,a,512,'whole')
%
% �Q�l FREQZ, INVFREQZ, PHASEZ, FREQS, PHASEDELAY, GRPDELAY, FVTOOL.

%   Copyright 1988-2002 The MathWorks, Inc.
