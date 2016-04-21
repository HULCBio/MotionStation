% FIRRCOS �R�T�C�����[���I�tFIR�t�B���^�̐݌v
%
% B = FIRRCOS(N,Fc,DF,Fs)�́A�R�T�C�����[���I�t�J�ڑш������N���̃��[�p
% �X���`�ʑ�FIR�t�B���^���o�͂��܂��B���̃t�B���^�́A�J�b�g�I�t���g��Fc�A
% �T���v�����O���g��Fs�A�J�ڕ�DF�ŁA�P�ʂ�Hz�ł��B
%
% Fc +/- DF/2�́A[0 Fs/2]�͈̔͂ɑ��݂���K�v������܂��B   
%
% �W��B�́A�m�~�i���Ȓʉߑш�̃Q�C�������1�ɂȂ�悤�ɐ��K������܂��B
%
% FIRRCOS(N,Fc,DF)�́A�f�t�H���g�̃T���v�����O���g���Ƃ��āAFs = 2���g��
% �܂��B
%
% B = FIRRCOS(N,Fc,R,Fs,'rolloff')�́A3�Ԗڂ̈�����^���邱�ƂŁA�J�ڕ�
% DF�̑���Ƀ��[���I�t�t�@�N�^���w�肷�邱�Ƃ��ł��܂��B
%
% R�́A0��1�̊ԂɂȂ�悤�Ȓl�łȂ���΂Ȃ�܂���B
%
% B = FIRRCOS(N,Fc,DF,Fs,TYPE)�A�܂��� B = FIRRCOS(N,Fc,R,Fs,'rolloff',
% TYPE)�́A����TYPE�ɋ�s����w�肷�邩 'normal'���w�肷��ƁA���K�̂ȃR
% �T�C�����[���I�tFIR�t�B���^��݌v���܂��B�܂��A����TYPE��'sqrt'��^��
% ��Ɠ�捪�R�T�C�����[���I�tFIR�t�B���^��݌v���܂��B
% 
% B = FIRRCOS(...,TYPE,DELAY)�́A�����x�����w�肷�邱�Ƃ��ł��܂��BDELAY
% �������ȗ����邩�A��̏ꍇ�́AN������������ɂ���āA�f�t�H���g�l�� 
% N/2 ��(N+1)/2 �ɂȂ�܂��B
% 
% DELAY�́A[0,N+1]�͈͓̔��̒l�ł��B
%
% B = FIRRCOS(...,DELAY,WINDOW)�́A ����N+1�̃E�B���h�E��݌v�����t�B��
% �^�ɓK�p���āA���g�������ɂ����郊�b�v�������������邱�Ƃ��ł��܂��B
% WINDOW�͒���N+1�̒�����x�N�g���łȂ���΂Ȃ�܂���BWINDOW���w�肵��
% ���ꍇ�́A���`�E�B���h�E���g���܂��B
%
% �x��:
% �f�t�H���g�l�ȊO�̒x�����������E�B���h�E���g���ꍇ�͒��ӂ��Ă��������B
%
% [B,A] = FIRRCOS(...)�́A��� A = 1 ���o�͂��܂��B
% 
% �Q�l�F   FIRLS, FIR1, FIR2.



%   Copyright 1988-2002 The MathWorks, Inc.
