% SPECGRAM   �M������X�y�N�g���O�������v�Z 
% B = SPECGRAM(A,NFFT,Fs,WINDOW,NOVERLAP) �́A�x�N�g�� A �̐M���ɑ΂���
% �X�y�N�g���O�������v�Z���܂��BSPECGRAM �́A�I�[�o���b�v����Z�O�����g
% �ɐM���𕪊����AWINDOW �x�N�g�����g���āA�X�ɃE�C���h�E�������s���A
% ���� NFFT ���Z���ꍇ�A�[����t�����āA���U�t�[���G�ϊ����s���܂��B��
% ���āAB �̊e��́A�M�� A �̒Z���� - �Ǐ��I�Ȏ��g���������܂ނ��ƂɂȂ�
% �܂��B���Ԃ́AB �̗�����ɁA������E�֐��`�ɑ������܂��B���g���́A�ŏ�
% ��0�ŁA�s�����ɏォ�牺�ɐ��`�ɑ������܂��BA ������ NX �̕��f���M����
% �ꍇ�AB �́ANFFT �s k(= fix((NX-NOVERLAP)/(length(WINDOW)-NOVERLAP)))
% ��̕��f���s��ɂȂ�܂��BA �������̏ꍇ�AB �� K�� �̂܂܂ł����A����
% ���g���̗v�f�́A�K�v�Ȃ��̂ŁA�؂����Ă��܂��B���̏ꍇ�ASPECGRAM 
% �́ANFFT �������̏ꍇ�ANFFT/2+1 �s�A��̏ꍇ�A(NFFT+1)/2 �s������ B 
% ���o�͂��܂��BWINDOW �ɃX�J���l��ݒ肷��ꍇ�ASPECGRAM �́A���̒l�̒�
% ����Hanning �E�C���h�E���g�p���܂��BWINDOW �́ANFFT �Ɠ������A�܂��͒Z
% ���ANOVERLAP ���傫���Ȃ���΂Ȃ�܂���BNOVERLAP �́AA �̕���������
% �蓯�u�̕��������ʂ��Ďg�p����T���v�����ł��BFs �́A�T���v�����O���g
% ���ŁA�X�y�N�g���O�����̌��ʂɂ́A�e����^�����A�v���b�g�̂��߂ɃX�P�[
% �����O�ɂ̂ݎg�p������̂ł��B
%
% [B,F,T] = SPECGRAM(A,NFFT,Fs,WINDOW,NOVERLAP) �́A�X�y�N�g���O�������v
% �Z�������g�� F �Ǝ��� T ���ɏo�͂��܂��BF �́AB ��T �̍s���Ɠ�������
% ���ŁAk�ɂȂ�܂��BFs ��ݒ肵�Ă��Ȃ��ꍇ�ASPECGRAM �́A2Hz �̃f�t�H
% ���g�ݒ�l���g���܂��B
% 
% B = SPECGRAM(A) �́A�f�t�H���g�ݒ���g���āA�M�� A �̃X�y�N�g���O����
% ���쐬���܂��B�f�t�H���g�l�́ANFFT �́A256��A �̒����̓��A�Z���l�A����
% NFFT �� Hanning�E�C���h�E�ANOVERLAP = length(WINDOW)/2 �ł��B�f�t�H��
% �g�l���g�p����ꍇ�́A�g�p�������f�t�H���g�ݒ�l�ȍ~�̃p�����[�^���ȗ�
% ���邩�A��s����g�p���܂��B���Ƃ��΁ASPECGRAM(A,[],1000) �ł��B
%
% �o�͈�����ݒ肵�Ȃ��ŁASPECGRAM���g�p����ƁA�J�����g�� Figure �� 
% IMAGESC(T,F,20*log10(ABS(B))), AXIS XY, COLORMAP(JET) ���g���āA�X�y�N
% �g���O�����̐�Βl���v���b�g���܂��B�����āA�M���̍ŏ��̕����̒���g��
% ���́A���̍������ɕ\������܂��B
%
% SPECGRAM(A,F,Fs,WINDOW) �́AF �����g���l�� Hz �P�ʂŕ\���� 2�v�f �x�N
% �g���̏ꍇ�A�����̎��g���ԂŁA20���傫�����Ԋu�ɕ����������g����
% chirp z �ϊ��܂��̓|���t�F�[�Y�Ԉ����t�B���^�o���N�̂����ꂩ���g���āA
% �X�y�N�g�����v�Z���܂��B
%
% �Q�l�F   PWELCH, CSD, COHERE, TFE.



%   Copyright 1988-2002 The MathWorks, Inc.
