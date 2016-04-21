% BTNGROUP   �c�[���o�[�{�^���O���[�v�̍쐬
% 
% H = BTNGROUP('Property1', value, 'Property2', value, ...) �́A�c�[���o�[
% �{�^���O���[�v���쐬���Aaxes�̃n���h���ԍ���H�ɏo�͂��܂��B
% H = BTNGROUP(FIGHANDLE�A'Property1'�Avalue�A...) �́A�{�^���O���[�v���A
% FIGHANDLE �Ŏ��ʂ����figure�ɐݒ肵�܂��B
% [H,HB] = BTNGROUP(...) �́Aaxes�I�u�W�F�N�g�̑���ɁA�X�^�C���v�b�V��
% �{�^���ƃg�O���{�^����uicontrol ����{�^���Q���쐬���܂��B���Z�̂��� 
% ���[�h�ŁAaxes �Ƃ��̎q�I�u�W�F�N�g�͍쐬�ł��܂����A�����ԂɂȂ�
% �܂��B���Ȃ킿�Auicontrol�� cdata ���Agetframe ��ʂ��ăC���[�W�L���v�`��
% ���瓾����̂ŁA�{�^���Q�̈ʒu�̃v���p�e�B�͋�Őݒ肳��Ă��邱�Ƃ�
% ���ӂ��Ă��������BHB �́A�{�^���Q�Ɋւ��� uicontrol �n���h���ԍ���
% �x�N�g���ł��B���̃��[�h�ŁA�{�^���ɑ΂���C���[�W�L���v�`�����������
% ���߂� 'Cdata' �v���p�e�B��n���܂�(���̂��߁A�֐����z�[���h���Ȃ���
% �R�[������O��axes�̈ʒu��K�v�Ƃ��܂�)�B
% 
% �K�v�ȃv���p�e�B: 
%     'GroupID'  - �{�^���O���[�v�̎��ʎq�̕�����B
%     'ButtonID' - �e�X�̃{�^���ɑ΂��鎯�ʎq�̕�������܂ލs��B������
%                  ButtonID �́A�����ɃX�y�[�X���܂�ł͂����܂���B
%
% �I�v�V�����̃v���p�e�B:
%     'IconFunctions' - �A�C�R���̕`��̕\�����܂ޕ�����܂��͕����񂩂�
%                       �Ȃ�s��B�����񂩂�Ȃ�s��̏ꍇ�AButtonID �Ɠ���
%                       �s���łȂ���΂Ȃ�܂���B�A�C�R���̕`��̕\���́A
%                       �J�����g��axes���ō쐬�����I�u�W�F�N�gHG�̃n���h��
%                       �ԍ����o�͂��܂��B�I�u�W�F�N�gHG�́A�͈� [0 1 0 1]��
%                       �`�悳��܂��B
% 
%     'Cdata'         - �{�^���ɑ΂���3���� cdata �s��̃Z���z��B����
%                       �v���p�e�B�́A���Z��'uicontrol'���[�h�A���Ȃ킿�A
%                       2�Ԗڂ̏o�͈��� HB �����݂���ꍇ�̃I�v�V�����̂�
%                       �ł��邱�Ƃɒ��ӂ��Ă��������B���̃p�����[�^��
%                       �p�ӂ���Ă���ꍇ�́A'IconFunctions' �v���p�e�B��
%                       ��������邱�Ƃɒ��ӂ��Ă��������B
% 
%    'PressType'      - 'flash'(���ꂪ�������ƁA�{�^���̓|�b�v�_�E��
%                       ���Ă��猳�ɖ߂�܂�)�A�܂��� 'toggle'(�{�^����
%                       ��Ԃ�ύX���A"sticks" ���܂�)�̂����ꂩ�ł��B
%                       'PressType'�́A������܂��͕�����s��ł��B������
%                       �s��̏ꍇ�́AButtonID �Ɠ����s���łȂ���΂Ȃ�
%                       �܂���B�f�t�H���g�́A'toggle'�ł��B
%                       
%    'Exclusive'      - 'yes'(�{�^���O���[�v�̓��W�I�{�^���̂悤�ȋ�����
%                       ���܂�)�܂��� 'no' �ł��B'yes' �̏ꍇ�́A'PressType'
%                       �v���p�e�B�͖�������܂��B�f�t�H���g�́A'no'�ł��B
% 
%    'Callbacks'      - �{�^���������ꂽ��Ԃ����������Ƃ��]�������\��
%                       ���܂ޕ�����B�l�́A������A�܂��́A������s��ł��B
%                     
%   'ButtonDownFcn'   - �{�^���������ꂽ�Ƃ��]������镶����l�́A������
%                       �ł��A�����񂩂�Ȃ�s��ł��\���܂���B
% 
%   'GroupSize'       - �{�^���̃��C�A�E�g���w�肷��2�v�f�̃x�N�g��
%                       ([nrows ncols])�B
%                       �f�t�H���g�́A[numButtons 1] �ł��B
% 
%   'InitialState'    - 0(�{�^�����ŏ��ɉ�����Ă��Ȃ�)��1(�{�^�����ŏ���
%                       ������Ă���)��v�f�Ƃ���x�N�g���B�f�t�H���g�́A
%                       zeros(numButtons, 1) �ł��B
% 
%   'Units'           - �{�^���O���[�v��axes�̒P�ʁB�f�t�H���g�́Afigure
%                       �̃f�t�H���g��axes�̒P�ʂł��B
% 
%   'Position'        - �{�^���O���[�v��axes�̈ʒu�B�f�t�H���g�́Afigure��
%                       �f�t�H���g��axes�̈ʒu�ł��B
% 
%   'BevelWidth'**    - �{�^���̕��ɑ΂���3�����̎΂߂̕��̊����B�f�t�H���g
%                       �́A0.05�ł��B
% 
%   'ButtonColor' **  - �����{�^���̃o�b�N�O�����h�J���[figure�� 
%                       DefaultUIControlBackgroundColor ���f�t�H���g�ł��B
% 
%   'BevelLight'**      - �E�΂ߏ���̏����̃J���[�B
% 
%   'BevelDark'**       - �E�΂߉����̏����̃J���[�B
%
% ** ���ӁF���̃v���p�e�B�́A'uicontrol' ���[�h����폜����܂����B
%          BevelWidth, ButtonColor, BevelLight, BevelDark
% 
% ���:
%         icons = ['text(.5,.5,''B1'',''Horiz'',''center'')'
%                  'text(.5,.5,''B2'',''Horiz'',''center'')'];
%         callbacks = ['disp(''B1'')'
%                      'disp(''B2'')'];
%         btngroup('GroupID', 'TestGroup', 'ButtonID', ...
%             ['B1';'B2'], 'Callbacks', callbacks, ...
%             'Position', [.475 .45 .05 .1], 'IconFunctions', icons);
%
%  �Q�l�F BTNSTATE, BTNPRESS, BTNDOWN, BTNUP, BTNRESIZE.


%  Steven L. Eddins, 29 June 1994
%  Tom Krauss, 27 June 1999 - Added uicontrol functionality
%  Copyright 1984-2002 The MathWorks, Inc. 
%  $Revision: 1.8.4.1 $  $Date: 2004/04/28 02:07:42 $
