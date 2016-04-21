% VERCTRL   PC�v���b�g�t�H�[����ł̃o�[�W�����Ǘ�����
%
% List = VERCTRL('all_systems') �́A�J�����g�̃}�V���ɃC���X�g�[������Ă���
% ���ׂẴo�[�W�����Ǘ��V�X�e���̈ꗗ���o�͂��܂��B
% 
% fileChange = VERCTRL(COMMAND,FILENAMES,HANDLE) �́AFILENAMES �� COMMAND 
% �Ŏw�肳���o�[�W�����Ǘ�������s���܂��B����́A�t�@�C������Ȃ�Z���z
% ��ł��BHANDLE �́A�E�B���h�E�̃n���h���ł��B�����̃R�}���h�́A�f�B�X�N
% ��̃t�@�C�����ύX���ꂽ�ꍇ�A���[�N�X�y�[�X�ɘ_���l1���A�ύX����Ă��Ȃ�
% �ꍇ�A0��Ԃ��܂��B
% FILENAMES �����ŗ��p�\��COMMAND�̒l�͈ȉ��̒ʂ�ł��B
% 
%     'get'           �\������уR���p�C���̂��߂Ƀt�@�C��(�P���܂���
%                     ����)���擾���܂����A�ҏW�͍s���܂���B(�P���܂���
%                     ������)�t�@�C���́A�Q�Ƃ݂̂ł��B�t�@�C���̈ꗗ�́A
%                     �t�@�C���܂��̓f�B���N�g���̂����ꂩ���܂݂܂����A
%                     �����͊܂݂܂���B 
% 
%     'checkout'      (�P���܂��͕�����)�t�@�C����ҏW�p�Ɏ擾���܂��B 
%
%     'checkin'       (�P���܂��͕�����)�t�@�C�����o�[�W�����Ǘ��V�X�e��
%                     �Ń`�F�b�N���܂��B�ύX��ۑ����ĐV�o�[�W�������쐬
%                     ���܂��B                        
%
%     'uncheckout'    �O�̃`�F�b�N�A�E�g������L�����Z�����A�I�����ꂽ
%                     �P���܂��͕����̃t�@�C���̓��e��precheckout�o�[�W����
%                     �Ƀ��X�g�A���܂��B�`�F�b�N�A�E�g��ɍs��ꂽ���ׂ�
%                     �̃t�@�C���ɑ΂���ύX�͎����܂��B
%
%     'add' 	      �o�[�W�����Ǘ��V�X�e���Ƀt�@�C����ǉ����܂��B 
%                       
%
%     'history'       �t�@�C���̗�����\�����܂��B
%
% VERCTRL(COMMAND,FILENAMES,HANDLE) �́A�t�@�C���̃Z���z��ł��� FILENAMES
% �� COMMAND �Ŏw�肳�ꂽ�o�[�W�����Ǘ��V�X�e�������s���܂��B
% HANDLE �́A�E�B���h�E�̃n���h���ł��B
% FILENAMES �����ŗ��p�\�� COMMAND �̒l�́A�ȉ��̒ʂ�ł��B
% 
%     'remove'         �o�[�W�����Ǘ��V�X�e������t�@�C�����폜���܂��B
%                      ���[�U�̃��[�J���n�[�h�h���C�u����̓t�@�C����
%                      �폜���܂���B�o�[�W�����Ǘ��V�X�e������݂̂ł��B
%
% fileChange = VERCTRL(COMMAND,FILE,HANDLE) �́A��̃t�@�C���ł��� FILE ��
% COMMAND �Ŏw�肳�ꂽ�o�[�W�����Ǘ��V�X�e�������s���܂��BHANDLE �́A�E�B��
% �h�E�̃n���h���ł��B�����̃R�}���h�́A�f�B�X�N��̃t�@�C�����ύX���ꂽ
% �ꍇ�A���[�N�X�y�[�X�ɘ_���l1���A�ύX����Ă��Ȃ��ꍇ�A�_���l0��Ԃ��܂��B
% FILENAMES �����ŗ��p�\�� COMMAND �̒l�́A�ȉ��̒ʂ�ł�
%
%     'properties'     �t�@�C���̃v���p�e�B��\�����܂��B
%                      
%     'isdiff'         �t�@�C�����o�[�W�����Ǘ��V�X�e�����̃t�@�C����
%                      �ŐV�`�F�b�N�o�[�W�����Ɣ�r���܂��B�t�@�C����
%                      �قȂ�ꍇ��1���o�͂��A�t�@�C��������ł���
%                      �ꍇ��0���o�͂��܂��B
%
% VERCTRL(COMMAND,FILE,HANDLE) �́A��̃t�@�C���ł��� FILE �� COMMAND ��
% �w�肳�ꂽ�o�[�W�����Ǘ��V�X�e�������s���܂��BHANDLE �́A�E�B���h�E��
% �n���h���ł��B
% FILENAMES �����ŗ��p�\�� COMMAND �̒l�́A�ȉ��̒ʂ�ł�
%                      
%     'showdiff'       �t�@�C���ƃo�[�W�����Ǘ��V�X�e�����̍ŐV�`�F�b�N
%                      �o�[�W�����̃t�@�C���̍�����\�����܂��B 
% 
% ���̊֐��́APC�v���b�g�t�H�[����̈قȂ�o�[�W�����Ǘ��R�}���h���T�|�[�g
% ���܂��BHANDLE���������o�[�W�����Ǘ��R�}���h���Ăяo���O�ɃE�B���h�E��
% �쐬���A�n���h�����擾����K�v������܂��B�E�B���h�E�쐬�̊�{�I�ȗ���
% �ȉ��Ɏ����܂��B 
% 
% ���:
% Java�E�B���h�E���쐬���A�n���h�����擾���܂��B
%    import java.awt.*;
%	 frame = Frame('Test frame');
%	 frame.setVisible(1);
%	 winhandle = com.mathworks.util.NativeJava.hWndFromComponent(frame)
%  
%     winhandle =
%
%         919892 
%
% �}�V���ɃC���X�g�[������Ă��邷�ׂẴo�[�W�����Ǘ��V�X�e���̈ꗗ���R�}
% ���h�E�B���h�E�ɏo�͂��܂��B.
%   List = verctrl('all_systems')
%   List =     
%               'Microsoft Visual SourceSafe'
%               'Jalindi Igloo'
%               'PVCS Source Control'
%               'ComponentSoftware RCS'   
% 
% �o�[�W�����Ǘ��V�X�e������ D:\file1.ext ���`�F�b�N�A�E�g���܂��B
% ���̃R�}���h�́A'checkout' �E�B���h�E���I�[�v�����A�f�B�X�N��̃t�@�C����
% �ύX����Ă���΃��[�N�X�y�[�X�ɘ_���l1���A�ύX����Ă��Ȃ����0��Ԃ��܂��B
%   fileChange = verctrl('checkout',{'D:\file1.ext'},winhandle)
%     
% �o�[�W�����Ǘ��V�X�e���� D:\file1.ext �� D:\file2.ext ��ǉ����܂��B
% ���̃R�}���h�́A'add' �E�B���h�E���I�[�v�����A�f�B�X�N��̃t�@�C����
% �ύX����Ă���΃��[�N�X�y�[�X�ɘ_���l1���A�ύX����Ă��Ȃ����0��
% �Ԃ��܂��B
%   fileChange = verctrl('add',{'D:\file1.ext','D:\file2.ext'},winhandle)
%     
% D:\file1.ext �̃v���p�e�B��\�����܂��B���̃R�}���h�́A'properties' 
% �E�B���h�E���I�[�v�����A�t�@�C�����ύX����Ă��ă����[�h����K�v������
% �ꍇ�́A�R�}���h�E�B���h�E��1���o�͂��܂��B
%   fileChange = verctrl('properties','D:\file1.ext',winhandle)
%   
% �Q�l �F CHECKIN,CHECKOUT,UNDOCHECKOUT,CMOPTS 


  
%   Copyright 1998-2002 The MathWorks, Inc.
