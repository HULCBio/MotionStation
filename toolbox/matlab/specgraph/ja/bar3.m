% BAR3   3�����o�[�v���b�g
% 
% BAR3(Y,Z) �́AM �s N ��̍s�� Z �̗���A����3�����o�[�v���b�g�Ƃ���
% �`�悵�܂��B�x�N�g�� Y �́A�P�������܂��͒P�������łȂ���΂Ȃ�܂���B 
%
% BAR3(Z) �́A�f�t�H���g�l Y = 1:M ���g�p���܂��B���͂��x�N�g���̏ꍇ�́A
% BAR3(Y,Z) �܂��� BAR3(Z) �́ALENGTH(Z) �̃o�[��`�悵�܂��B�J���[�́A
% �J���[�}�b�v�ɂ��ݒ肳��܂��B
%
% BAR3(Y,Z,WIDTH) �܂��� BAR3(Z,WIDTH) �́A�o�[�̕����w�肵�܂��B
% WIDTH ��1�����傫����΁A�o�[�͏d�ˏ�������܂��B�f�t�H���g�l�́A
% WIDTH = 0.8 �ł��B
%
% BAR3(...,'detached') �́A�f�t�H���g�̕��������o�[�v���b�g���쐬���܂��B
% BAR3(...,'grouped') �́A�O���[�v�������o�[�v���b�g���쐬���܂��B
% BAR3(...,'stacked') �́A1�̃o�[�Ɋe�v�f��ςݏd�˂āA�o�[�v���b�g��
% �쐬���܂��B
% BAR3(...,LINESPEC) �́A�w�肵�����C���J���[('rgbymckw' �̂����ꂩ)��
% �g�p���܂��B
%
% BAR3(AX,...) �́AGCA�̑����AX�Ƀv���b�g���܂��B
%
% H = BAR3(...) �́Asurface�I�u�W�F�N�g�̃n���h���ԍ�����Ȃ�x�N�g����
% �o�͂��܂��B
%
% ���:
%       subplot(1,2,1), bar3(peaks(5))
%       subplot(1,2,2), bar3(rand(5),'stacked')
%
% �Q�l�FBAR, BARH, BAR3H.


%   Mark W. Reichelt 8-24-93
%   Revised by CMT 10-19-94, WSun 8-9-95
%   Copyright 1984-2002 The MathWorks, Inc.
