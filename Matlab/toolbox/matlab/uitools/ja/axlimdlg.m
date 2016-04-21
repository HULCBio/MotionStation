% AXLIMDLG   Axes limits�_�C�A���O�{�b�N�X
% 
% FIG = AXLIMDLG(DlgName,OptionFlags,PromptString,AxesHandles,....
%       XYZstring,DefLim, ApplyFcn) �́ADlgName �Ƃ������O�ŁAPromptString
% �̍s�ŗ^������v�����v�g�����AAxes limits�_�C�A���O�{�b�N�X���쐬
% ���܂��B
% 
% OptionFlags  - �t���O����Ȃ�s�x�N�g��
%                1���: �����͈͐ݒ�`�F�b�N�{�b�N�X(1 = yes�A0 = no)
%                2���: �ΐ��X�P�[���`�F�b�N�{�b�N�X(1 = yes�A0 = no)
%                �f�t�H���g�́A�����Ƃ�off�ł��B
% PromptString - �e�s���v�����v�g�e�L�X�g�ł��镶����s��
% AxesHandles  - axis�̃x�N�g���BNaN�́APromptString �ɏ]����axes�𕪊�
%                ���܂��B
% XYZstring    - PromptString �Ɠ����s���̕�����s��
% DefLim       - PromptString �Ɠ����s���̕�����s��
% ApplyFcn     - Apply�{�^���R�[���o�b�N�ɕt����������P��s�̕�����B
%                �_�C�A���O���󂳂��O�ɁA�_�C�A���O���當�����͈͂�
%                ���o����̂ɖ𗧂��܂��B
%
% ��� 1
% 
%    axlimdlg
% 
% �́Agca �R�}���h�ŋ@�\����W����axes limit�_�C�A���O�{�b�N�X���o�͂��܂��B
% 
% ��� 2
% 
%    axlimdlg('MyName')
% 
% �́Agca �R�}���h�ŋ@�\���� MyNam e�Ƃ������O�̕W����axes limits�_�C�A��
% �O�{�b�N�X���o�͂��܂��B
% 
% ��� 3
% 
%    axlimdlg('MyName',[1 1])
% 
% �́Agca �R�}���h�ŋ@�\���� MyName �Ƃ������O��axes limits�_�C�A���O�{�b�N
% �X���쐬���A�����͈͐ݒ�Ƒΐ�/���`�X�P�[���ɂ��Ẵ`�F�b�N�{�b�N�X
% �������܂��B
% 
% ��� 4
% 
% GainAx �� PhaseAx �́ABode�v���b�g��axes�̃n���h���ԍ��ł��B
% 
%    DlgName = 'Bode axes limit dialog';
%    OptionFlags = [0 0];
%    PromptString = str2mat('Frequency range:','Gain Range:',...
%        'Phase range:');
%    AxesHandles = [GainAx PhaseAx NaN GainAx NaN PhaseAx];
%    XYZstring = ['x'; 'y'; 'y'];
%    DefLim = [get(GainAx,'XLim'); get(GainAx,'YLim'); ...
%       get(PhaseAx,'YLim')];
%    axlimdlg(DlgName,OptionFlags,PromptString,AxesHandles,...
%       XYZstring,DefLim)
%
% ����:
% 1) �_�C�A���O�ɂ́AEditCallback �܂��� ApplyCallback�Ƃ������O���g��Ȃ���
%    �������B
% 2) ���axes�܂��͐������Ȃ�axes�̃n���h���ԍ���ݒ肷��Ƃ��ɂ́A
%    �G���[�_�C�A���O���쐬���Ă��������B�L�\�ȃA�v���P�[�V�����v���O���}�́A��
%    �̏ꍇ�́A�_�C�A���O�{�b�N�X����axes�n���h�����X�V���邩�A�K�v�Ȃ�_�C
%     �A���O�{�b�N�X���󂻂��Ƃ��܂��B
% 3) Figure UserData �́A�e�X�� PromptString �̍s [PromptText EditField 
%    AutoCheckbox LogCheckbox] �ɑ΂��āA1�s�̃n���h�����܂݂܂��B
% 4) PromptText UserData �́Aaxes�̃n���h���ԍ����܂݂܂��B
% 5) EditField UserData �́A�L���Ȏ��͈̔͂��܂݂܂��B
% 6) �g�b�v�t���[��uicontrol UserData�́AXYZstring���܂݂܂��B


%   Author(s): A. Potvin, 10-25-94, 1-1-95
%   Copyright 1984-2002 The MathWorks, Inc.
%   $Revision: 1.10.4.1 $  $Date: 2004/04/28 02:07:40 $

