% RBBOX  ���o�[�o���h�{�b�N�X
%
% RBBOX �́A�J�����gfigure���̃��o�[�o���h�{�b�N�X�����������A�g���b�N
% ���܂��B����́A�{�b�N�X�̏��������`�T�C�Y��0�ɐݒ肵�Afigure�� 
% CurrentPoint �Ƀ{�b�N�X��z�u���A���̓_����̃g���b�L���O���n�߂܂��B
%
% RBBOX(initialRect) �́A[x y width heigh] ���g���āA���o�[�o���h�̏�����
% �ʒu�ƃT�C�Y��ݒ肵�܂��B�����ŁAx �� y �͍��������Awidth �� height ��
% �傫����ݒ肵�܂��BinitialRect �́A�J�����gfigure�� Units �v���p�e�B
% �ɂ��ݒ肳���P�ʂŁAfigure�̍��������瑪��܂��B�|�C���^�̈ʒu��
% �ł��߂��{�b�N�X�̋��́ARBBOX ���{�^���A�b�v�̃C�x���g���󂯓����܂ŁA
% �|�C���^�̓����ɏ]���܂��B
%
% RBBOX(initialRect,fixedPoint) �́A�Œ肵���܂܂̃{�b�N�X�̋���ݒ肵�܂��B
% ���ׂĂ̈����́A�J�����gfigure�� Units �v���p�e�B�Ŏw�肳��Afigure 
% �E�B���h�E�̍��������瑪��܂��BfixedPoint �́A2�v�f [x,y]����Ȃ�
% �x�N�g���ł��B�g���b�L���O�|�C���g�́AfixedPoint �Œ�`���ꂽ�Œ�̋�
% ����Ίp�̊֌W�ɂ���������Ɉړ����܂��B
%
% RBBOX(initialRect,fixedPoint,stepSize) �́A���o�[�o���h�{�b�N�X���X�V
% �����p�x��ݒ肵�܂��B�g���b�L���O�|�C���g��figure�̒P�� stepSize ��
% ������ꍇ�́ARBBOX �̓��o�[�o���h�{�b�N�X���ĕ`�悵�܂��B�f�t�H���g�� 
% stepSize ��1�ł��B
%
% finalRect = RBBOX(...) �́A4�v�f [x y width height] ����\�������x�N
% �g���ŁAx �� y �� �{�b�N�X�̍������� x �� y �̍��W�ŁAwidth �� height 
% �̓{�b�N�X�̑傫���ł��B
%
% �}�E�X�{�^���́ARBBOX ���R�[�������ꍇ�Ƀ_�E����ԂɂȂ�܂��B
% RBBOX �́AWAITFORBUTTONPRESS �Ƌ��ɁAButtondownFcn �̒��܂��� M-�t�@�C��
% �̂����ꂩ�Ŏg�����Ƃ��ł��A�_�C�i�~�b�N�ȋ����𐧌䂷�邱�Ƃ��ł��܂��B
%
% ���F
%
%   figure;
%   pcolor(peaks);
%   k = waitforbuttonpress;
%   point1 = get(gca,'CurrentPoint');    % �{�^���_�E���̌��o
%   finalRect = rbbox;                   % figure�P�ʂ̏o��
%   point2 = get(gca,'CurrentPoint');    % �{�^���A�b�v�̌��o
%   point1 = point1(1,1:2);              % x �� y �̒��o
%   point2 = point2(1,1:2);
%   p1 = min(point1,point2);             % �ʒu�Ƒ傫���̌v�Z
%   offset = abs(point1-point2);         % 
%   x = [p1(1) p1(1)+offset(1) p1(1)+offset(1) p1(1) p1(1)];
%   y = [p1(2) p1(2) p1(2)+offset(2) p1(2)+offset(2) p1(2)];
%   hold on
%   axis manual
%   plot(x,y,'r','linewidth',5)          % �{�b�N�X�̉��ɑI������
%                                        % �̈�̕`��
%
% �Q�l�FWAITFORBUTTONPRESS, DRAGRECT.


%   Copyright 1984-2002 The MathWorks, Inc.
%   $Revision: 1.9.4.1 $  $Date: 2004/04/28 02:08:44 $
%   Built-in function.
