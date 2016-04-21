% MATLAB�̒������Java�̎g�p
%
% ���[�U�́A�N���X�����g���āAMATLAB�̒�����Java�I�u�W�F�N�g���쐬�ł���
% ���B
%
%    >> f = java.awt.Frame('My Title')
%
%    f =
%
%    java.awt.Frame[frame0,0,0,0x0,invalid,hidden,layout=java.awt.Border
%    Layout,resizable,title=my title]
%
% ����MATLAB�V���^�b�N�X���g���Ă��AJava�I�u�W�F�N�g�̃��\�b�h���Ăяo��
% ���Ƃ��ł��܂��B
%       >> setTitle (f, 'new title' )
%       >> t = getTitle(f)
%   
%       t =
%   
%       new title
%
% Java�V���^�b�N�X���g���Ă��AJava�I�u�W�F�N�g�̃��\�b�h���Ăяo�����Ƃ��ł���
% ���B
%       >> f.setTitle ('new title' )
%       >> t = f.getTitle
%   
%       t =
%   
%       new title
%
% ���̗��ł́Af �͏�L�ō쐬���ꂽ java.awt.Frame �I�u�W�F�N�g�ŁAgetTitle 
% �� setTitle �́A���̃I�u�W�F�N�g�̃��\�b�h�ł��B
%
% �ύX����ы������ꂽ�g�ݍ��݊֐�
%
% METHODS
% �֐�METHOD�́AJava�̃N���X���������Ƃ��Ď󂯓���܂��BMETHODS�́A
% -full �t���Ŏg�p�ł��܂��B-full �́AMETHOD�ɁAJava�̃N���X�̂��ׂĂ�
% ���\�b�h�̑S�L�q���o�͂����܂��B���̒��ɂ́AJava�N���X�̒��̃��\�b�h��
% �V�O�l�`����g�p�Ɋւ��鑼�̏����܂܂�Ă��܂��B
% 
% METHODS�́A-full �Ȃ��ŁA���ׂĂ̏d�����Ă��閼�O���폜�����R���p�N�g��
% ���\�b�h���X�g���o�͂��܂��B
%
% FIELDNAMES
% �֐�FIELDNAMES�́AJava�I�u�W�F�N�g�������Ƃ��Ď󂯓���܂��BFIELDNAMES
% ���܂��A-full �t���Ŏg�p�ł��܂��B-full �́AJava�I�u�W�F�N�g�̂��ׂẴp
% �u���b�N�ȃt�B�[���h�̊��S�Ȑ�����\�������܂��B���̒��ɂ́A�����A�^�C
% �v�A�p�����܂�ł��܂��B-full �Ȃ���FIELDNAMES�́A�R���p�N�g�ȃt�B�[��
% �h�����X�g���o�͂��܂��B
%
% ISA
% ISA�֐����AJava�̃N���X�����󂯓���܂��B�z�񂪎w�肵��Java�N���X�̃�
% ���o�̏ꍇ�A�܂��́A�w�肵��Java�N���X����̃N���X�p���̏ꍇ�P���o�͂�
% �܂��B���Ƃ��΁Aisa(x, 'java.awt.Frame')�A isa(x, 'java.awt.Component'),
% isa(x, 'java.lang.Object')�́Ax���N���Xjava.awt.Frame�̃I�u�W�F�N�g��
% �܂�ł���ƁA���ׂ�1���o�͂��܂��B
%
% EXIST
% �֐�EXIST�́A2�Ԗڂ̈��� 'class' ���󂯓���܂��BEXIST �́A�ŏ��̈���
% ��MATLAB��Java�N���X�p�X���Java�N���X���̏ꍇ�A8���o�͂��܂��B
%
% CLASS
% �֐�CLASS�́AJava�I�u�W�F�N�g��Java�N���X�����o�͂�����悤�ɋ�������
% �܂��B
%
% DOUBLE
% DOUBLE �́Ajava.lang.Integer, java.lang.Byte���̂悤�� java.lang.Number
% ����p������邷�ׂĂ�Java�I�u�W�F�N�g��I�u�W�F�N�g��Java�z���
% MATLAB�� double �ɕϊ����邽�߂ɃI�[�o���[�h����܂����B'toDouble'
% ���\�b�h���܂ޔC�ӂ�Java�N���X�́AMATLAB���g���āA���̃N���X�̃I�u
% �W�F�N�g��MATLAB�� double �ɕϊ����邱�Ƃ��ł��܂��B���Ȃ킿�AMATLAB�́A
% Java�N���X�̒���'toDouble'���\�b�h���R�[�����āA���̂悤�ȃI�u�W�F�N�g��
% MATLAB�� double �ɕϊ����܂��B
%
% CHAR
% CHAR �́A���ׂĂ� java.lang.String �I�u�W�F�N�g��MATLAB�L�����N�^
% �z��ɕϊ�������Ajava.lang.String �̂��ׂĂ�Java�z����L�����N�^��
% MATLAB�z��ɕϊ����邽�߂ɃI�[�o���[�h����܂����B'toChar'���\�b�h��
% �܂ޔC�ӂ�Java�N���X�́AMATLAB���g���āA���̃N���X�̃I�u�W�F�N�g�� 
% MATLAB�L�����N�^�ɕϊ��ł��܂��B���Ȃ킿�AMATLAB�́AJava�N���X�̒�
% ��'toChar'���\�b�h���R�[�����āA���̂悤�ȃI�u�W�F�N�g��MATLAB�L����
% �N�^�ɕϊ����܂��B
%
% INMEM
% INMEM�́A�I�v�V������3�Ԗڂ̏o�͈������󂯓����悤�Ɋg������Ă���
% ���B���ɐݒ肷��ƁA����3�Ԗڂ̈����́A���[�h����邷�ׂĂ�Java�N���X��
% ���X�g���o�͂��܂��B
%
% WHICH
% WHICH�́A����������ƈ�v���郁�\�b�h�ɑ΂��āA���ׂẴ��[�h���ꂽ
% Java�N���X��T�����܂��B
% 
% CLEAR
% CLEAR IMPORT�́A�x�[�X�C���|�[�g���X�g���N���A���܂��B
%
% SIZE
% �֐�SIZE��Java�z��ɓK�p�����ƁA�o�͂����s����Java�z��̒�
% ���ŁA�񐔂͏��1�ɂȂ�܂��BSIZE ���z���Java�z��ɓK�p�����ƁA��
% �ʂ́A�z�񂩂�Ȃ�z��̈�ԏ�̃��x���̔z��݂̂��L�q���܂��B
%
% �V�����g�ݍ��݊֐�
%
% METHODSVIEW
% �֐� METHODSVIEW �́A�w�肵���N���X�Ŏ�������邷�ׂẴ��\�b�h�̏�
% ���\�����܂��BMETHODSVIEW �́A�V�����E�B���h�E���쐬���A�ǂ݂₷���e
% �[�u���t�H�[�}�b�g�ŁA�������������܂��B
%
% METHODSVIEW PACKAGE_NAME.CLASS_NAME �́AJava�N���X 
% PACKAGE_NAME �̃p�b�P�[�W���痘�p�\��Java�N���X CLASS_NAME ��
% �L�q�������\�����܂��B
%
% METHODSVIEW CLASS_NAME �́A�C���|�[�g���ꂽJava�N���X�܂���MATLAB
% �N���X CLASS_NAME ���L�q�������\�����܂��B
%
% ���
% % java.awt.MenuItem �N���X�̒��̂��ׂẴ��\�b�h�Ɋւ���������X�g���܂��B
%   methodsview java.awt.MenuItem
%
% IMPORT  �J�����gJava�p�b�P�[�W�ƃN���X�C���|�[�g���X�g�ɕt�����܂��B
% IMPORT PACKAGE_NAME* �́A�w�肵���p�b�P�[�W�����J�����g�C���|�[�g���X
% �g�ɕt�����܂��BIMPORT PACKAGE_NAME.CLASS_NAME �́A�w�肵��Java�N��
% �X���C���|�[�g���܂��B
%
% IMPORT PACKAGE1.* PACKAGE2.CLASS_NAME ... �́A�����̃p�b�P�[�W��t
% �����邽�߂Ɏg�p���܂��B
%
% L = IMPORT(...)�́AIMPORT�̏I�����ɁAIMPORT�����݂���Ƃ��A�J�����g��
% �C���|�[�g���X�g�̓��e�𕶎���̃Z���z��Ƃ��Ă��̒ʂ�ɏo�͂��܂��B
%
% L = IMPORT�́A���͂�^���Ȃ��ꍇ�́A�J�����g�̃C���|�[�g���X�g�𓾂܂��B
% �����ł́A�t���������̂͂���܂���B
%
% IMPORT �́A�g�p�������̂̒��ŁA�֐��̃C���|�[�g���X�g�݂̂ɉe����^��
% �܂��B�R�}���h�v�����v�g�Ŏg����x�[�X�C���|�[�g���X�g�����݂��܂��B
% IMPORT���X�N���v�g���Ŏg����ƁA�X�N���v�g��ǂݍ��ފ֐��̃C���|�[�g���X
% �g�ɉe����^���邩�A�܂��̓X�N���v�g���R�}���h�v�����v�g����ǂݍ��܂ꂽ
% �ꍇ�́A�x�[�X�C���|�[�g���X�g�ɉe����^���܂��B
%
% CLEAR IMPORT �́A�x�[�X�C���|�[�g���X�g���N���A���܂��B
%
% ���
%       import java.awt.*
%       import java.util.Enumeration java.lang.*
%       f = Frame;               % java.awt.Frame�I�u�W�F�N�g���쐬
%       s = String('hello');     % java.lang.String�I�u�W�F�N�g���쐬
%       methods Enumeration      % java.util.Enumeration���\�b�h�̃��X�g
% 
%  ISJAVA  Java�I�u�W�F�N�g�̌��o
%  ISJAVA(J)�́AJ��Java�I�u�W�F�N�g�̏ꍇ�P�A���̏ꍇ0���o�͂��܂��B
%
% �R���X�g���N�^���A�w�肵���N���X�⎯�ʎq�ƈ�v���Ă��Ȃ��ꍇ�A�G���[��
% �����܂��B
%
% javaArray
% �֐� javaArray �́A�w�肵������������Java�z����쐬���܂��B
%
% JA = javaArray(CLASS_NAME,DIM1,...) �́AJava�z��I�u�W�F�N�g(Java�̎�
% �������I�u�W�F�N�g)���o�͂��A���̗v�f�N���X�́A�L�����N�^������ 
% CLASSNAME �Ŏw�肵��Java�N���X�ł��B
%
% ���
%   % 10x5 java.awt.Frame Java �z����쐬
%     ja = javaArray('java.awt.Frame',10,5);
%
% javaMethod 
%   �֐� javaMethod �́A�w�肵��Java���\�b�h��ǂݍ��݂܂��B
%
%   X = javaMethod(METHOD_NAME,CLASS_NAME,X1,...,Xn) �́AX1,...,Xn �ƈ�v
%   ����������X�g�����N���X CLASS_NAME ���� static ���\�b�h METHOD_
%   NAME ��ǂݍ��݂܂��B
%
%   javaMethod(METHOD_NAME,J,X1,...,Xn) �́AX1,...,Xn �ƈ�v����������X
%   �g�����I�u�W�F�N�g J ���nonstatic ���\�b�h METHOD_NAME ��ǂݍ���
%   �܂��B
%
% ���
%   % nonstatic ���\�b�h setTitle ��ǂݍ��݂܂��B�����ŁAframeObj �́A
%   % java.awt.Frame �I�u�W�F�N�g�ł��B
%     frameObj = java.awt.Frame;
%     javaMethod('setTitle', frameObj, 'New Title');
%
% javaObject
%   �֐� javaObject �́A�w�肵��Java�N���X�̃I�u�W�F�N�g���쐬���܂��B
%
%   J = javaObject(CLASS_NAME,X1,...,Xn) �́AX1,...,Xn �Ɉ�v����������X
%   �g�����N���X CLASS_NAME �p��Java�R���X�g���N�^��ǂݍ���ŁA�V��
%   ���I�u�W�F�N�g���o�͂��܂��B
%
% ���
%   % �N���X java.lang.String ��Java�I�u�W�F�N�g���쐬���A�o�͂��܂��B
%     strObj = javaObject('java.lang.String','hello')
%
% Caveats
%
% 1�̃T�u�X�N���v�g�݂̂��g���āA�z�񂩂�Ȃ�Java�z�񂪃C���f�b�N�X�t��
% ���ꂽ�ꍇ�A�߂�l�́A�z�񂩂�Ȃ�z��̃g�b�v���x���z��ɂȂ�A�z�񂩂�
% �Ȃ�z��̐��`���`���̃X�J���v�f�ł͂���܂���B

