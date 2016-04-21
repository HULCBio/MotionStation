% FFTW �́AFFT �v�Z���œK�����܂��B
% 
% FFTW('measure',N) �́A���[�U�̌v�Z�@��ŁAN-�_�� FFT �̍ő吔�����s��
% ��Ƃ��́A�ő��̎�@�����肵�܂��B���s���茋�ʂ́AMATLAB �̒��ɃL���b
% �V������AFFT, IFFT, FFT2, IFFT2, FFTN, IFFTN �ŏ����g�p����ꍇ�ɃX�s
% �[�h�A�b�v�̂��߂Ɏg���܂��B����t�@�N�^��N �Ƃ���C�ӂ̃T�C�Y��1��
% ���A2�����AN ������ FFT �́A�œK���ɂ�艶�b���󂯂܂����A�v�Z���Ԃ́A
% �g�p����v�Z�@�ɂ���X�ɕω����܂��B�ꍇ�ɂ���ẮA�S�����ǂ������
% �Ȃ����̂�����܂��B
%
% S = FFTW('wisdom') �́A���s���Ԃ̍œK���p�̑��茋�ʂ��܂Ƃ߂����̂��A
% ������Ƃ��ďo�͂��܂��B���̕�����́A������ MATLAB �Z�b�V�����Ŏg�p��
% �邽�߂ɁAMAT-�t�@�C���Ƃ��ăZ�[�u���邱�Ƃ��ł��܂��B
%
% FFTW('wisdom',S) �́AS ���O������ FFTW �Ōv�Z�������ʂ�����������̏�
% ���A���s���Ԃ̍œK�����Ƃ��ďd�v�Ȃ��̂ɂȂ�܂��B���[�U�� MATLAB �Z
% �b�V�����̒��ŁA����������I�Ɏg�p����ɂ́ALOAD �R�}���h���g���āAMAT-
% �t�@�C�����當���� S �����[�h���āAFFTW ���R�[������悤�ɁA���[�U��
% STARTUP.m �ɐݒ肵�Ă��������B
%
% FFTW('wisdom',[])�A�܂��́AFFTW('wisdom','') �́A���ׂẴX�g�A���� 
% FFT �̍œK���Ɋւ�������N���A���܂��B
%
% FFTW �́AFFT �v�Z�ɁAMATLAB ���g�p���郉�C�u�����̖��O�ł��B�����āA
% FFTW �֐��́A���̃��C�u�����̍œK���@�\�̂������Ƃ̃C���^�t�F�[�X��
% ���BFFTW ���C�u�����Ɋւ�����́Ahttp://www.fftw.org ���Q�Ƃ��Ă���
% �����B
%
% ���
% -------
%       x = rand(512,512);
%       % �f�t�H���g�A���S���Y�����g�����ꍇ�� FFT �̌v�Z����
%       tic, for k = 1:10, y = fft2(x); end, toc  
%       % ���[�U�̎g�p����v�Z�@�ɂ��l���v�Z����܂��B
%       fftw('measure',512) 
%       % �ēx�AFFT �̎��Ԃ��v��
%       tic, y = fft2(x); toc
%       % ���s���Ԃ̏��� MATLAB �� wisdom.mat �Ɩ��t���� M �t�@�C����
%       % �X�g�A
%       s = fftw('wisdom');
%       save wisdom s
%       % �X�g�A���Ă�����s���ԏ�������
%       fftw('wisdom',[])
%       % �Z�[�u���Ă�����s���ԏ����ēx���[�h
%       load wisdom s
%       fftw('wisdom',s)
%
% �Q�l�FFFT, FFT2, FFTN, IFFT, IFFT2, IFFTN.

% $Revision: 1.3 $ $Date: 2002/06/17 13:28:56 $
%   Copyright 1984-2002 The MathWorks, Inc.
