% LISTDLG   ���X�g�I���_�C�A���O�{�b�N�X
% 
% [SELECTION,OK] = LISTDLG('ListString',S) �́A���X�g���當����܂���
% �����̕������I���ł���_�C�A���O�{�b�N�X���쐬���܂��BSELECTION �́A
% �I������������̃C���f�b�N�X�̃x�N�g���ł�(�I������1�̃��[�h�ł́A
% ����1�ł�)�BOK��0�̂Ƃ��� [] �ł��B
% ���[�U��OK�{�^����������OK��1�ŁACancel�{�^����������figure����������
% �ƁAOK��0�ł��B
%
% �����̃A�C�e�����I�������ꍇ�́A1�̃A�C�e����Ń_�u���N���b�N��
% ���邩�A�܂��́A<CR>�������ƁAOK�{�^������������ԂƓ����@�\�������܂��B
% <CR>���������Ƃ́AOK�{�^�����N���b�N���邱�ƂƓ����ł��B<ESC>��������
% �Ƃ́ACancel�{�^�����N���b�N���邱�ƂƓ����ł��B
%
% ���͂́A�p�����[�^�ƒl�̑g���킹�ł��B
%
% �p�����[�^		�ڍ�
% 'ListString'	   ���X�g�{�b�N�X�ɑ΂��镶����̃Z���z��
% 'SelectionMode'  ������B'single' �܂��� 'multiple'�B�f�t�H���g��
%                  'multiple' �ł��B
% 'ListSize'       ���X�g�{�b�N�X��[width height] (�s�N�Z���P��)�B
%                  �f�t�H���g�́A[160 300]�ł��B
% 'InitialValue'   ���X�g�{�b�N�X�̂ǂ̃A�C�e�����ŏ��ɑI������Ă��邩��
%                  �����C���f�b�N�X�̃x�N�g���B�f�t�H���g�́A�ŏ��̃A�C
%                  �e���ł��B
% 'Name'           figure�̃^�C�g���ɑ΂��镶����B�f�t�H���g�́A''�ł��B
% 'PromptString'   ���X�g�{�b�N�X�̏�Ƀe�L�X�g�Ƃ��ĕ\������镶����
%                  �s��A�܂��́A�����񂩂�Ȃ�Z���z��B�f�t�H���g�́A
%                  {}  �ł��B
% 'OKString'       OK�{�^���ɑ΂��镶����B�f�t�H���g�́A'OK'�ł��B
% 'CancelString'   Cancel�{�^���ɑ΂��镶����B�f�t�H���g�́A'Cancel'�ł��B
%
% ������I������ꍇ�ɂ́A'Select all' �{�^�����񋟂���Ă��܂��B
%
% ���:
%     d = dir;
%     str = {d.name};
%     [s,v] = listdlg('PromptString','Select a file:',...
%                     'SelectionMode','single',...
%                     'ListString',str)


%   T. Krauss, 12/7/95, P.N. Secakusuma, 6/10/97
%   Copyright 1984-2002 The MathWorks, Inc.
