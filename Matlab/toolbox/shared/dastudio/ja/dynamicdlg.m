% DYNAMICDLGS   �����I��MathWorks���g�p���邽�߂̃_�C�i�~�b�N�_�C�A���O
%               �̍쐬
%
% DYNAMICDLG(m-struct | file) �́A�_�C�A���O�̃��C�A�E�g���`���邽�߂�
% �n���ꂽ�\����/MAT-�t�@�C�������g�p���܂��B���̋@�\��Java Swing��
% �T�|�[�g��K�v�Ƃ��܂��B
% �_�C�A���O�\���̂̍\���̂̓��e�͈ȉ��̂Ƃ���ł��B
%
%       dlgstruct -
%          - DialogTitle
%          - Tab_1
%               - Name
%               - Group_1
%                    - Name
%                    - NameVisible
%                    - BoxVisible
%                    - WidthFactor (�I�����R�A�f�t�H���g = 100)
%                    - Widget_1
%                         - Name (�v�b�V���{�^���A�e�L�X�g�A���x���A
%                                 ���W�I�{�^���ŕK�v�ɂȂ�܂�)
%                         - Type
%                         - ObjectProperty | ObjectMethod | MatlabMethod 
%                           (������1��I�����܂�)
%                         - MethodArgs (�I�����R�AObjectMethod ��
%                                       MatlabMethod �Ƌ��Ɏg���܂�)
%                         - DialogCallback (�I�����R�A�_�C�A���O���X�V
%                                           �������ꍇ�Ɏg�p���܂�)
%                                           dialog to update itself)
%                         - ToolTip  (�I�����R�A�f�t�H���g = '')
%                         - Enabled
%                         - Visible
%                         - Editable (�I�����R�A�R���{�{�b�N�X�ɑ΂���
%                                     �̂ݎg���܂��B�f�t�H���g = false)
%                         - Entries (���X�g�{�b�N�X�A�R���{�{�b�N�X�A
%                                    ���W�I�{�^���ŕK�v�ɂȂ�܂�)
%                         - SelectedItem (�I�����R�A���X�g�{�b�N�X�A
%                                         �R���{�{�b�N�X�A���W�I�{�^���A
%                                         �`�F�b�N�{�b�N�X�Ŏg���܂�)
%                         - WidthFactor (�I�����R�A�f�t�H���g = 100) 
%                       :
%                    - Widget_N
%                  :
%               - Group_N
%              :
%          - Tab_N
%  
% �ȉ��̕��i�������_�ŃT�|�[�g����Ă��܂��B
%     pushbutton     radiobutton       list        edit          combobox 
%     editarea       text              label       checkbox      hyperlink
%
% Group_N ����� Widget_N ���� 'WidthFactor' �t�B�[���h�́A���C�A�E�g��
% ���������邽�߂Ɏg�p�ł���C�ӂ̃t�B�[���h�ł��B�f�t�H���g�ł́A100��
% �ݒ肳��Ă���A1�s�ɂ�1�̕��i���z�u����܂��B�����10����100�̊Ԃ�
% �C�ӂ̒l��ݒ肷�邱�Ƃ��ł��܂��B�e�s�̍��v��100�ɂȂ�悤�ɁA�e���i��
% �΂��镝�̗v�f��I���������ɕ��i����ׂĔz�u���܂��B
% �_�C�A���O�쐬�́A�����̃_�C�A���O�̊T�v�̓��{��o�[�W�����̍쐬��
% �ۑ��̂��߂ɕK�v�ł��邱�Ƃɒ��ӂ��Ă��������B�����Java���\�[�X
% �o���h���𗘗p���邱�ƂŎg�p�\�ɂȂ�܂��B
%
% �Q�l : MODELEXPLORER.


%   Copyright 2002 The MathWorks, Inc.
