% EXCLUDEDATA   �폜�����f�[�^�̃}�[�N�t��
% OUTLIERS = EXCLUDEDATA(XDATA,YDATA,'METHOD',VALUE) �́AXDATA �� YDATA 
% �Ɠ����傫�������_���x�N�g���ŁA�v�f1�́A��������_�A0�͍폜���Ȃ��_
% ��\�킵�܂��B�}�[�N�����_�́A������'METHOD'�Ɗ֘A���� VALUE  �Ɉˑ�
% ���܂��B
% 
% METHOD �� VALUE �ɑ΂��āA���̂��̂̒�����I���ł��܂��B
%
%   Indices - �ُ�l�Ƃ��ă}�[�N�����X�̓_�̃C���f�b�N�X��v�f�Ƃ���
%             �x�N�g��
%   Domain  - [XMIN XMAX] ���͈̔͊O���ُ�l�Ƃ��ă}�[�N����͈͂��w��
%             ����l
%   Range   - [YMIN YMAX] ���̃����W�O���ُ�l�Ƃ��ă}�[�N���郌���W��
%             �w�肷��l
%   Box     - [XMIN XMAX YMIN YMAX] ���͈̔͊O���ُ�l�Ƃ��ă}�[�N����
%             �{�b�N�X���w�肷����W
%
% ������g�ݍ��킹��ɂ́A| (or) ���Z�q���g���܂��B  
%
% ���F
%    outliers = excludedata(xdata, ydata, 'indices', [3 5]);
%    outliers = outliers | excludedata(xdata, ydata, 'domain', [2 6]);
%    fit1 = fit(xdata,ydata,fittype,'Exclude',outliers);
%
% �������̏ꍇ�A���ׂẴf�[�^��ێ����邽�߂ɁA����炷�ׂĂ��܂ރ{�b
% �N�X���w�肵�����ꍇ������܂��BEXCLUDEDATA ���g���āA������s���ɂ́A
% NOT (~) ���g���܂��B
%
%    outliers = ~excludedata(xdata,ydata,'box',[2 6 2 6])
%
% �Q�l   FIT

% $Revision: 1.2.4.1 $
%   Copyright 2001-2004 The MathWorks, Inc.
