% SPA �́A�X�y�N�g����͂��s���܂��B
% 
%   G = SPA(DATA)  
%
%   DATA : IDDATA �I�u�W�F�N�g�̌^�ŕ\�����o�� - ���̓f�[�^(HELP IDDATA
%          ���Q��)
%   G    : IDFRD �I�u�W�F�N�g�̌^�ŕ\�������g�������ƕs�m�������o��
%          ���f�� y = G u + v �̃m�C�Y v �̃X�y�N�g�����܂܂�Ă��܂��B
%          help IDFRD ���Q�Ƃ��Ă��������B
%
% DATA �����n��̏ꍇ�AG �́A���肵���X�y�N�g���Ɛ��肵���s�m�����Ƌ���
% �o�͂���܂��B
%
% �X�y�N�g���́A���O�T�C�Y min(length(DATA)/10,30) ������ Hamming �E�C��
% �h�E�𗘗p���Čv�Z����܂��BG = SPA(DATA,M) �Ǝ��s���邱�ƂŁA���O�T�C
% �Y�� M �ɕύX���邱�Ƃ��ł��܂��B
% 
% �֐��́A0����΂܂ł̊Ԃ�128�����ɕ������Čv�Z����܂��B�֐��́AG = SPA
% (DATA,M,w) ���g���āA(�֐� LOGSPACE �ō쐬����)�C�ӂ̎��g�� w �Ōv�Z��
% �邱�Ƃ��ł��܂��B
%    
% G = SPA(DATA,M,w,maxsize) ���g���āA�������ƃX�s�[�h�̃g���[�h�I�t���s
% ���܂��BIDPROPS ALGORITHM ���Q�Ƃ��Ă��������B
%
% �f�[�^�ɑ�����͂��܂܂��ꍇ�A
% 
%   [Gtf,Gnoi,Gio] = SPA(DATA, ... )
% 
% �́A3�̈قȂ� IDFRD ���f���̏����o�͂��܂��B
% 
% Gtf �́A���͂���o�͂܂ł̓`�B�֐��̐�����܂�ł��܂��B
% Gnoi �́A�o�͕��z v �̃X�y�N�g�����܂�ł��܂��B
% Gio �́A�o�̓`�����l���A���̓`�����l���̑g�ݍ��킹�ɂ��X�y�N�g���s��
% ���܂�ł��܂��B
%
% �Q�l�F IDMODEL/BODE, IDMODEL/NYQUIST, ETFE, IDFRD

%   L. Ljung 10-1-86, 29-3-92 (mv-case),11-11-94 (complex data case)


%   Copyright 1986-2001 The MathWorks, Inc.
