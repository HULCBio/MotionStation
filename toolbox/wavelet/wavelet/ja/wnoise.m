% WNOISE�@ �G�����܂񂾃E�F�[�u���b�g�e�X�g�f�[�^���쐬
% X = WNOISE(FUN,N) �́A[0,1] �͈̔͂� 2^N �T���v����ŁAFUN �ɂ��e�X�g�֐���
% �l���o�͂��܂��B
%
% [X,XN] = WNOISE(FUN,N,SNRAT) �́A��q�̂悤�Ƀe�X�g�x�N�g�� X ���o�͂��A�W����
% �� std(x) = SNRAT �ƂȂ�悤�ɍăX�P�[�����O���܂��B�o�͂��ꂽ�x�N�g�� XN �́A
% �x�N�g���̒l X �ɁA���Z�I�ȃK�E�X���F�G�� N(0,1) ���d�˂�ꂽ���̂ł��BXN �́A
% �M���ƎG���̔䂪 SNRAT �ł��B
%
% [X,XN] = WNOISE(FUN,N,SNRAT,INIT) �́A�x�N�g�� X �� XN ���o�͂��܂����A������
% ���߂̗����V�[�h�Ƃ��� INIT ���p�����܂��B
%
% ����6�̊֐����ADonoho �� Johnstone �ɂ��"Adapting to unknown smoothness 
% via wavelet shrinkage"  Preprint Stanford�Ajanuary 93�Ap 27-28.�ɂ����ďЉ
% ��Ă��܂��B
%   FUN = 1 �܂��� FUN = 'blocks'     
%   FUN = 2 �܂��� FUN = 'bumps'      
%   FUN = 3 �܂��� FUN = 'heavy sine'   
%   FUN = 4 �܂��� FUN = 'doppler'   
%   FUN = 5 �܂��� FUN = 'quadchirp'   
%   FUN = 6 �܂��� FUN = 'mishmash'     
% 



%   Copyright 1995-2002 The MathWorks, Inc.
