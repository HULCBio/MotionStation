% FRDATA   ���g�������f�[�^�ւ̃N�C�b�N�A�N�Z�X
%
%
% [RESPONSE,FREQ] = FRDATA(SYS) �́A���g�������f�[�^(FRD)���f�� SYS ��
% �����f�[�^�Ǝ��g���T���v�����o�͂��܂��B
%
% Nw �̎��g���_�ł� Nu ���� Ny �o�͂̒P��̃��f�� SYS �ł́ARESPONSE��
% Ny*Nu*Nw �̔z��ɂȂ�A(I,J,K)�̗v�f�͎��g�� FREQ(K) �ł� J �Ԗڂ̓���
% ���� I �Ԗڂ̏o�͂܂ł̉����ɂȂ�܂��BFREQ �́AFRD �̎��g���T���v����
% �܂ޒ��� Nw �̗�x�N�g���ł��B
%
% [RESPONSE,FREQ,TS] = FRDATA(SYS) �́A�T���v������ TS ���o�͂��܂��B
% SYS �̂��̑��̃v���p�e�B�́AGET ��p���ĎQ�Ƃ��邩���ړI�ɍ\���̃��C�N��
% �Q�Ƃł��܂�(���Ƃ��΁ASYS.Ts)�B
%
% �P���SISO���f�� SYS �ɑ΂��āA���� 
%   [RESPONSE,FREQ] = FRDATA(SYS,'v') 
% �́A3�����z��ł͂Ȃ��A��x�N�g���Ƃ��� RESPONSE ���o�͂��܂��B
%
% Nu ���́ANy �o�͂ŁANw �̎��g���_����Ȃ� FRD ���f���� S1*S2*...*Sn �z��
% SYS�ɑ΂��āARESPONSE �́A�T�C�Y [Ny Nu Nw S1 S2 ... Sn] �̔z��ƂȂ�A
% �����ŁARESPONSE(:,:,K,p1,p2,...,pn) �́A���g�� FREQ(K) �ł̃��f�� 
% SYS(:,:,p1,p2,...,n) �̉����ƂȂ�܂��B
%
% �Q�l : FRD, GET, LTIMODELS, LTIPROPS.


% Copyright 1986-2002 The MathWorks, Inc.
