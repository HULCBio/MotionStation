% BENCH   MATLAB �x���`�}�[�N
%
% BENCH �́A6��ނ�MATLAB�̎��s���Ԃ𑪒肵�A����̃R���s���[�^�̎��s
% ���x�Ɣ�r���܂��B6��ނ̍�Ƃ͂��̂��̂ł��B
%   
%    LU       LAPACK, n = 1000.       ���������_�A�ʏ�̃������A�N�Z�X
%    FFT      Fast Fourier�ϊ�.       ���������_�A�ʏ�łȂ��������A�N�Z�X
%    ODE      Ordinary diff. eqn.     �f�[�^�\���̂�M-�t�@�C��
%    Sparse   �X�p�[�X�V�X�e���̉�@. �����ƕ��������_���̍���
%    2-D      plot(fft(eye)).         2�����̃��C���`��
%    3-D      MathWorks���S           3������OpenGL�O���t�B�b�N�X�A�j���[
%                                     �V����
%
% �Ō�ɕ\�������o�[�`���[�g�́A���Ԃɔ���Ⴗ��ʂƂ��đ��x�������Ă�
% �܂��B�����o�[�͑����}�V���ŁA�Z���o�[���x���}�V���������܂��B
%
% BENCH �́A6��ނ̍�Ƃ�1����s���܂��B
% BENCH(N) �́A6��ނ̍�Ƃ� N ����s���܂��B
% BENCH(0) �́A���̃R���s���[�^�Ɣ�r�������Ԃ݂̂��o�͂��܂��B
% T = BENCH(N) �́A���s���Ԃ�v�f�Ƃ���N�s6��̔z����o�͂��܂��B
%
% ���̃R���s���[�^�ɑ΂����r�f�[�^�́A���̃e�L�X�g�t�@�C���ɕۑ������
% ���܂��B
%
%      .../toolbox/matlab/demos/bench.dat
%
% ���̃t�@�C���̃A�b�v�f�[�g���ꂽ�o�[�W�����́AMATLAB Central�������
% �\�ł��B
%
%      http://www.mathworks.com/matlabcentral/fileexchange/loadFile.do?
%           objectId=1836&objectType=file#
%
% �P��}�V����ł̌J��Ԃ����s�̊ϑ����x�́A5%�܂���10%�̕ϓ���������
% ���B���[�U���g�̂��̂ł́A�قȂ�ꍇ������܂��B
%
% ���̃x���`�}�[�N�́A��X�̃}�V���Ԃł̓���̃o�[�W�����̃p�t�H�[�}���X
% ���r���邱�Ƃ��Ӑ}���Ă��܂��BMATLAB�̎�X�̃o�[�W�����Ԃł̔�r��
% �Ӑ}���Ă��܂���B���e����̃T�C�Y�́A�o�[�W�������ɈقȂ��Ă��܂��B
%
% LU �� FFT �ɂ��ẮA�傫�ȍs��ƒ����x�N�g�����g���Ă��܂��B�]���āA
% �����I�ȃ�������64MB�������Ȃ��}�V����A�œK�����ꂽBasic Linear 
% Algebra Subprograms �������Ȃ��}�V���ł́A�p�t�H�[�}���X���ቺ����
% �ꍇ������܂��B
%
% 2������3�����̂��̂́AOpenGL���T�|�[�g���Ă���n�[�h�E�F�A�܂��̓\�t�g
% �E�F�A���܂ރO���t�B�b�N�X�̃p�t�H�[�}���X�𑪒肵�܂��B�R�}���h
%      opengl info
% �́A����̃}�V����ŗ��p�\��OpenGL�T�|�[�g���L�q���Ă��܂��B


%   Copyright 1984-2002 The MathWorks, Inc.
