% SGMLTAG - SGML�v�f�𕶖@�I�ɉ��߂����\��
% SGMLTAG�I�u�W�F�N�g�́A�ȉ��̃t�B�[���h�������܂��B
%   T.tag  - �^�O�̃e�L�X�g  <tag>
%   T.data - �^�O�̓��e�B���l�A������A���̑���SGMLTAG�I�u�W�F�N�g�A�Z��
%            �z����g�����Ƃ��ł��܂��B
%   T.att  - N�s2��̃Z���z��B��1�͑������ŁA��2�͑����l�ł��B
%   
% T.opt�́A�I�v�V�����x�N�g���ł��B
%       opt(1) = IndentContents.  �^�̏ꍇ�́Asubtags��cdata���C���f���g
%                ���܂��B
%       opt(2) = EndTag.  �^�̏ꍇ�́Aendtag��}�����܂��B
%       opt(3) = Expanded.  �^�̏ꍇ�́A�^�O�ƃf�[�^���A�ʂ̍s�ɒu���܂��B
%       opt(4) = SGML.  ���e��SGML�ł��B <,& ���G�X�P�[�v�L�����N�^�Œu
%                �������Ȃ��ł��������B
%
% SGMLTAG�I�u�W�F�N�g:
% 
%     T.tag='foo';
%     T.data='bar';
%     T.att={'att1',0;'att2',a};
%     T.opt=[1 1 1 0];
%
%   SGML�e�L�X�g:
% 
%       <foo att1=0 att2="a">
%          bar
%       </foo>
%
% �Q�l: SGMLTAG/CHAR, SGMLTAG/SET, SGMLTAG/SHOW





% $Revision: 1.1.6.1 $ $Date: 2004/03/21 22:23:39 $
%   Copyright 1997-2002 The MathWorks, Inc.
