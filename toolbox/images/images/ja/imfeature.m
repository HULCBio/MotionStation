% IMFEATURE   �C���[�W�̈�ɑ΂���`�󑪒�ɂ��Ă̌v�Z
%   STATS = IMFEATURE(L,MEASUREMENTS) �́A���x���s�� L ���̃��x���t��
%   ���ꂽ�A���ꂼ��̗̈�ɑ΂��āA����̏W�����v�Z���܂��BL �̐��̐�
%   ���v�f�͈قȂ�̈�ɑΉ����܂��B���Ƃ��΁A1�ɓ�����L�̗v�f�̏W��
%   �́A�̈�1�ɑΉ����܂��B2�ɓ�����L�̗v�f�̏W���́A�̈�2�ɑΉ�����
%   ���B�����āA�ȉ����l�ɂȂ�܂��BSTATS �́A���� max(L(:)) �̍\����
%   �z��ł��B�\���̔z��̃t�B�[���h�́AMEASUREMENTS �ɂ��ݒ肳���
%   ����悤�ɁA�e�̈�ɑ΂���قȂ鑪��������܂��B
%
%   MEASUREMENTS �́A�R���}�ŋ�؂�ꂽ������̃��X�g�A��������܂ރZ
%   ���z��A������ 'all'�A�܂��́A������ 'basic' ���g�p���邱�Ƃ��ł�
%   �܂��B�g�p�\�ȑ���̕�����̏W���́A�ȉ��̂Ƃ���ł��B
%
%     'Area'              'ConvexHull'    'EulerNumber'
%     'Centroid'          'ConvexImage'   'Extrema'
%     'BoundingBox'       'ConvexArea'    'EquivDiameter'
%     'MajorAxisLength'   'Image'         'Solidity'
%     'MinorAxisLength'   'FilledImage'   'Extent'
%     'Orientation'       'FilledArea'    'PixelList'
%     'Eccentricity'
%
%   ����̕�����́A�啶���A�������̋�ʂ��s���܂���B�����āA�ȗ��`��
%   �g�����Ƃ��ł��܂��B
%
%   MEASUREMENTS �������� 'all' �ł���ꍇ�A��q�̂��ׂĂ̑���ɂ���
%   �v�Z���܂��BMEASUREMENTS ��ݒ肵�Ȃ��ꍇ��A������ 'basic' �ł���
%   �ꍇ�ɂ� 'Area','Centroid','BoundingBox' �̑���ɂ��Čv�Z����
%   ���B
%
%   STATS = IMFEATURE(L,MEASUREMENTS,N) �́A����� 'FilledImage',
%   'FilledArea','EulerNumber' ���v�Z����ۂɎg���A���^�C�v��ݒ肵��
%   ���BN �ɂ́A4�A�܂��́A8�̂����ꂩ�̒l���g�p���邱�Ƃ��ł��܂��B��
%   �̂Ƃ��A4��4�A���I�u�W�F�N�g�A8��8�A���I�u�W�F�N�g��ݒ肵�܂��B��
%   �̈������ȗ�����ƁA�f�t�H���g��8��ݒ肵�܂��B
%
% �N���X�T�|�[�g
% -------------
% ���̓��x���s�� L �́Adouble �A�܂��́A�C�ӂ̐����̃N���X���T�|�[�g
% ���Ă��܂��B
%
% �Q�l : BWLABEL, ISMEMBER



%   Copyright 1993-2002 The MathWorks, Inc.
