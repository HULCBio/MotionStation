% CLASS   �I�u�W�F�N�g�̍쐬�A�܂��́A�I�u�W�F�N�g�̃N���X�̏o��
%
% C = CLASS(OBJ) �́A�I�u�W�F�N�gOBJ�̃N���X���o�͂��܂��B
% �\�ȃN���X�́A���̒ʂ�ł��B
%     double          -- �{���x���������_���l�z��
%                        (����́A�]���܂ł�MATLAB�̍s��܂��͔z��ł�)
%     logical         -- �_���z��
%     char            -- �L�����N�^�z��
%     cell            -- �Z���z��
%     struct          -- �\���̔z��
%     function_handle -- �֐��̃n���h��
%     int8            -- 8�r�b�g�����t�������z��
%     uint8           -- 8�r�b�g�����Ȃ������z��
%     int16           -- 16�r�b�g�����t�������z��
%     uint16          -- 16�r�b�g�����Ȃ������z��
%     int32           -- 32�r�b�g�����t�������z��
%     uint32          -- 32�r�b�g�����Ȃ������z��
%     <class_name>    -- �J�X�^���I�u�W�F�N�g�N���X
%     <java_class>    -- java�I�u�W�F�N�g��Java�N���X��
%
% CLASS�̂��̑��̂��ׂĂ̗��p�́A�f�B���N�g���� @<class_name>���̃t�@�C��
% �� <class_name>.m �̃R���X�g���N�^���\�b�h�Ƌ��ɋN������K�v������܂��B
% ����ɁA 'class_name' �́ACLASS��2�Ԗڂ̈����ɂȂ�܂��B
%
% O = CLASS(S,'class_name') �́A�\���� S ����N���X 'class_name' �̃I�u
% �W�F�N�g���쐬���܂��B
%
% O = CLASS(S,'class_name',PARENT1,PARENT2,...) �́A�e�I�u�W�F�N�g PARENT1, 
% PARENT2, ...���̃��\�b�h�ƃt�B�[���h���p�����܂��B
%
% O = CLASS(struct([]),'class_name',PARENT1,PARENT2,...) �́A��̍\���� S ��
% �w�肵�A1�܂��͕����̐e�N���X����p�������I�u�W�F�N�g���쐬���܂����A�e
% ����p������Ȃ��t���I�ȃt�B�[���h�͂���܂���B
%
% �Q�l �F ISA, SUPERIORTO, INFERIORTO, STRUCT.


%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.8.4.1 $  $Date: 2004/04/28 01:47:13 $
%   Built-in function.
