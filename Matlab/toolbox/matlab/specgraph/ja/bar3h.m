% BAR3H   ����3�����o�[�v���b�g
% 
% BAR3H(Y,Z) �́AM �s N ��̍s�� Z �̗���A����3�����o�[�Ƃ��ĕ`�悵�܂��B
% �x�N�g�� Y �́A�P�������܂��͒P�������łȂ���΂Ȃ�܂���B
%
% BAR3H(Z) �́A�f�t�H���g�l Y = 1:M ���g�p���܂��B���͂��x�N�g���̏ꍇ�A
% BAR3H(Y,Z) �܂��� BAR3H(Z)�́ALENGTH(Z) �̃o�[��`�悵�܂��B�J���[��
% �J���[�}�b�v�ɂ��ݒ肳��܂��B
%
% BAR3H(Y,Z,WIDTH) �܂��� BAR3(Z,WIDTH) �́A�o�[�̕���ݒ肵�܂��B
% WIDTH ��1�����傫����΁A�o�[�͏d�ˏ�������܂��B�f�t�H���g�l�́A
% WIDTH = 0.8 �ł��B
%
% BAR3H(...,'detached') �́A�f�t�H���g�̕��������o�[�v���b�g���쐬���܂��B
% BAR3H(...,'grouped') �́A�O���[�v�������o�[�v���b�g���쐬���܂��B
% BAR3H(...,'stacked') �́A1�̃o�[�Ɋe�v�f��ςݏd�˂āA�o�[�v���b�g��
% �쐬���܂��B
% BAR3H(...,LINESPEC) �́A�w�肵�����C���J���[('rgbymckw' �̂����ꂩ)��
% �g�p���܂��B
%
% BAR3H(AX,...) �́AGCA�̑����AX�Ƀv���b�g���܂��B
%
% H = BAR3H(...) �́Asurface�I�u�W�F�N�g�̃n���h���ԍ�����Ȃ�x�N�g����
% �o�͂��܂��B
% 
% ���:
%       subplot(1,2,1), bar3h(peaks(5))
%       subplot(1,2,2), bar3h(rand(5),'stacked')
%
% �Q�l�FBAR, BARH, BAR3.


%   Mark W. Reichelt 8-24-93
%   Revised by CMT 10-19-94, WSun 8-9-95
%   Copyright 1984-2002 The MathWorks, Inc. 
