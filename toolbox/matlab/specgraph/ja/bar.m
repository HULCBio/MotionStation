% BAR   �o�[�v���b�g
% 
% BAR(X,Y) �́AM �s N ��̍s�� Y �̗���AN �̐����o�[����Ȃ� M ��
% �O���[�v�Ƃ��ĕ`�悵�܂��B�x�N�g�� X �́A�P�������܂��͒P�������łȂ�
% ��΂Ȃ�܂���B
%
% BAR(Y) �́A�f�t�H���g�l X = 1:M ���g�p���܂��B���͂��x�N�g���̏ꍇ�́A
% BAR(X,Y) �܂��� BAR(Y) �́ALENGTH(Y) �̃o�[��`�悵�܂��B�J���[�́A
% �J���[�}�b�v�ɂ��ݒ肳��܂��B
%
% BAR(X,Y,WIDTH) �܂��� BAR(Y,WIDTH) �́A�o�[�̕���ݒ肵�܂��BWIDTH ��
% 1�����傫����΁A�o�[�͏d�ˏ�������܂��B�f�t�H���g�l�́AWIDTH = 0.8 
% �ł��B
%
% BAR(...,'grouped') �́A�f�t�H���g�̃O���[�v�����������o�[�v���b�g��
% �쐬���܂��B
% BAR(...,'stacked') �́A1�̃o�[�Ɋe�v�f��ςݏd�˂āA�o�[�v���b�g��
% �쐬���܂��B
% BAR(...,LINESPEC) �́A�w�肵�����C���J���[('rgbymckw' �̂����ꂩ)��
% �g�p���܂��B
%
% BAR(AX,...) �́AGCA�̑����AX�Ƀv���b�g���܂��B
%
% H = BAR(...) �́Abar�V���[�Y�I�u�W�F�N�g�̃n���h���ԍ�����Ȃ�x�N�g��
% ���o�͂��܂��B
%
% �o�[�̃G�b�W��\������ɂ́ASHADING FACETED ���g�p���Ă��������B
% �G�b�W�������ɂ́ASHADING FLAT ���g�p���Ă��������B
%
% ���:  
% �@�@�@�@�@�@subplot(3,1,1), bar(rand(10,5),'stacked'), colormap(cool)
%             subplot(3,1,2), bar(0:.25:1,rand(5),1)
%             subplot(3,1,3), bar(rand(2,3),.75,'grouped')
%
% �Q�l�F HIST, PLOT, BARH, BAR3, BAR3H.


%    C.B Moler 2-06-86
%    Modified 24-Dec-88, 2-Jan-92 LS.
%    Modified 8-5-91, 9-22-94 by cmt; 8-9-95 WSun.
%    Copyright 1984-2002 The MathWorks, Inc. 
