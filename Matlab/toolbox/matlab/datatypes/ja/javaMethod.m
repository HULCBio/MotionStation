% javaMethod   Java���\�b�h���N��
%
% javaMethod �́A�ÓI�ȁA�܂��͐ÓI�łȂ�Java���\�b�h���N�����邽�߂ɗp����
% ��܂��B
%
% M��Java���\�b�h�̖��O���܂ޕ�����ŁAC ��Java�N���X�̖��O���܂ޕ�����
% �̏ꍇ�́A
%
%   javaMethod(M,C,x1,...,xn)
%
% �́A���� x1,...,xn �ƈ�v���閼�O�����N���X C ��Java���\�b�hM���N��
% ���܂��B���Ƃ��΁A 
%   
%   javaMethod('isNaN', 'java.lang.Double', x)
%
% �́A�N���Xjava.lang.Double�̐ÓI��Java���\�b�hisNaN���N�����܂��B
%
% J ��Java�I�u�W�F�N�g�z��̏ꍇ�AjavaMethod(M,J,x1,...xn) �́A���� 
% x1,...xn �ƈ�v���閼�O������J�̃N���X�̔�ÓI��Java���\�b�hM���N��
% ���܂��B���Ƃ��΁AF ��java.awt.Frame Java �I�u�W�F�N�g�z��̏ꍇ�A
%
%   javaMethod('setTitle', F, 'New Title')
%
% �́A�t���[���ɑ΂��ă^�C�g����ݒ肵�܂��BjavaMethod �́A�ʏ킱�̌^��K�v
% �Ƃ����A�܂��g�����Ƃ�����܂���BJava�I�u�W�F�N�g���MATLAB���\�b�h���N��
% ����ʏ�̕��@�́AsetTitle(F, 'New Title')�̂悤��MATLAB���\�b�h�Ăяo���V
% ���^�b�N�X��AF.setTitle('New Title')�̂悤��Java�Ăяo���V���^�b�N�X��
% �����̂ł��BjavaMethod �́A(���S�ȃR���g���[�����K�v�Ƃ����悤��)
% �ʏ�̕��@�����p�ł��Ȃ��ꍇ�ɗ��p������̂ł��B
%
% �Q�l �F javaObject, IMPORT, METHODS, ISJAVA.


%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.4.4.1 $  $Date: 2004/04/28 01:47:37 $
