% BARH   �����o�[�v���b�g
% 
% BARH(X,Y) �́AM �s N ��̍s�� Y �̗���AN �̐����o�[����Ȃ�M��
% �O���[�v�Ƃ��ĕ`�悵�܂��B�x�N�g�� X �́A�P�������܂��͒P��������
% �Ȃ���΂Ȃ�܂���B
%
% BARH(Y) �́A�f�t�H���g�l X = 1:M ���g�p���܂�����͂��x�N�g���̏ꍇ�́A
% BARH(X,Y) �܂��� BARH(Y) �́ALENGTH(Y) �̃o�[��`�悵�܂��B�J���[�́A
% �J���[�}�b�v�ɂ��ݒ肳��܂��B
%
% BARH(X,Y,WIDTH)�܂���BARH(Y,WIDTH) �́A�o�[�̕����w�肵�܂��BWIDTH ��
% 1�����傫����΁A�o�[�͏d�ˏ�������܂��B�f�t�H���g�l�́AWIDTH = 0.8 
% �ł��B
%
% BARH(...,'grouped') �́A�f�t�H���g�̃O���[�v�����������o�[�v���b�g��
% �쐬���܂��B
% BARH(...,'stacked') �́A1�̃o�[�Ɋe�v�f��ςݏd�˂āA�o�[�v���b�g��
% �쐬���܂��B
% BARH(...,LINESPEC) �́A�w�肵�����C���J���[('rgbymckw' �̂����ꂩ)��
% �g�p���܂��B
% 
% BARH(AX,...) �́AGCA�̑����AX�Ƀv���b�g���܂��B
%
% H = BARH(...) �́Abar�V���[�Y�I�u�W�F�N�g�̃n���h���ԍ�����Ȃ�x�N�g��
% ���o�͂��܂��B
%
% ���ʌ݊���
% BARH('v6',...)�́AMATLAB 6.5����т���ȑO�̃o�[�W�����Ƃ̌݊����̂���
% bar�V���[�Y�I�u�W�F�N�g�̑����patch�I�u�W�F�N�g���쐬���܂��B
%
% �o�[�̃G�b�W��\������ɂ́ASHADING FACETED ���g�p���Ă��������B
% �G�b�W�������ɂ́ASHADING FLAT ���g�p���Ă��������B
%
% ���: 
%            subplot(3,1,1)�Abarh(rand(10,5),'stacked')�Acolormap(cool)
%            subplot(3,1,2), barh(0:.25:1,rand(5),1)
%            subplot(3,1,3), barh(rand(2,3),.75,'grouped')
%
% �Q�l�F PLOT, BAR, BAR3, BAR3H.


%    Copyright 1984-2002 The MathWorks, Inc. 
