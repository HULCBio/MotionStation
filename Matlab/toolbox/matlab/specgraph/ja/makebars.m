% MAKEBARS   �o�[�O���t�̂��߂̃f�[�^�̍쐬
% 
% [MSG,X,Y,XX,YY,LINETYPE,PLOTTYPE,BARWIDTH,EQUAL] = MAKEBARS(X,Y) �́A
% �I���W�i���̃f�[�^�l X �� Y�ABARxx m-�t�@�C��(BAR�ABARH�ABAR3�ABAR3H)
% �̂�����1���g���āA�v���b�g����鏑���t���f�[�^�l XX �� YY ���o��
% ���܂��B
% 
% LINETYPE �́A�v���b�g�ɑ΂��Ċ�]����J���[���o�͂��܂��B
% PLOTTYPE �́A�v���b�g���O���[�v������邩(PLOTTYPE = 0)�A�X�^�b�N����
% �邩(PLOTTYPE = 1)�A��������邩(PLOTTYPE = 2-3�����v���b�g�̂�)��
% �w�肵�܂��BBARWIDTH �́A(1�ɐ��K�����ꂽ)�o�[�̕��ł��B
%
% [MSG,X,Y,XX,YY,LINETYPE,PLOTTYPE,BARWIDTH,ZZ] = MAKEBARS(X,Y) �́A
% ��L�Ɠ��l�ł����A�Ō�̃p�����[�^ ZZ �́A3�����v���b�g BAR3 ��
% BAR3H �Ŏg�p�����z���̃f�[�^�ł��B
%
% [...] = MAKEBARS(X,Y,WIDTH) �܂��� MAKEBARS(Y,WIDTH) �́AWIDTH ��
% �^�����镝���o�͂��܂��B�f�t�H���g��0.8�ł��B
% [...] = MAKEBARS(...,'grouped') �́A��񂪃O���[�v������ăv���b�g
% �����悤�ȏ����ŁA�f�[�^���o�͂��܂��B
% [...] = MAKEBARS(...,'detached') {3�����̂�}�́A��񂪕ʁX�Ƀv���b�g
% �����悤�ɁA�f�[�^���o�͂��܂��B
% [...] = MAKEBARS(...,'stacked') �́A��񂪃X�^�b�N����鏑���Ńv���b�g
% �����悤�ɁA�f�[�^���o�͂��܂��B
% [...] = MAKEBARS(...,'hist') �́A�ς̕���bin���o�͂��܂��B
% [...] = MAKEBARS(...,'histc') �́A�G�b�W�ɐG���o�[���쐬���܂��B
% 
% �f�[�^�̊Ԋu����������΁AEQUAL �͐^�ł��B�����łȂ���΋U�ł��B
% plottype �� 'hist' �� 'histc' �ȊO�̂Ƃ��AEQUAL �͏�ɐ^�ł��B
%
% �Q�l�FHIST, PLOT, BAR, BARH, BAR3, BAR3H.


%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.9.4.1 $  $Date: 2004/04/28 02:05:22 $
