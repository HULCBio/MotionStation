% GMONOPULS �́AGaussian ���m�p���X������ł��B
% Y = GMONOPULS(T,FC) �́A�z�� T �Ŏ�����鎞�ԂŁA���S���g�� FC(Hz)
% ������ �P�ʐU��������Gaussian ���m�p���X�T���v�����o�͂��܂��B
% �f�t�H���g�́AFC = 1000 Hz �ł��B
%
% TC = GMONOPULS('cutoff',FC) �́A�p�X���̍ő�U���ƍŏ��U���̎���
% �Ԋu���o�͂��܂��B
%
% �f�t�H���g�l�́A��܂��́A�ȗ����邱�Ƃɂ��A�g�p�ł��܂�
%
% ���1�F100 GHz �̃��[�g�ŃT���v�����ꂽ2 GHz Gaussian ���m�p���X��
% �v���b�g���܂��傤�B
%       fc = 2E9;  fs=100E9;
%       tc = gmonopuls('cutoff', fc);
%       t  = -2*tc : 1/fs : 2*tc;
%       y = gmonopuls(t,fc); plot(t,y)
%
% ���2�F���1���g���āA7.5 nS �̊Ԋu�ŁA���m�p���X����쐬���܂��傤�B
%      fc = 2E9;  fs=100E9;           % ���S���g���A�T���v�����g��
%      D = [2.5 10 17.5]' * 1e-9;     % �p���X�x�ꎞ��
%      tc = gmonopuls('cutoff', fc);  % �e�p���X�Ԃ̕�
%      t  = 0 : 1/fs : 150*tc;        % �M�����v�Z���鎞��
%      yp = pulstran(t,D,@gmonopuls,fc);
%      plot(t,yp)
%
% �Q�l�F GAUSPULS, TRIPULS, PULSTRAN, CHIRP.



%   Copyright 1988-2002 The MathWorks, Inc.
