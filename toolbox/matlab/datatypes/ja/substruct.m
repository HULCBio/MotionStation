% SUBSTRUCT   SUBSREF�A�܂��́ASUBSASGN�̂����ꂩ�ɑ΂���\���̈�����
%             �쐬
%
% S = SUBSTRUCT(TYPE1,SUBS1,TYPE2,SUBS2,...) �́A�I�[�o���[�h���ꂽ 
% SUBSREF�A�܂��́ASUBSASGN���\�b�h�ɂ��K�v�ƂȂ�t�B�[���h������
% �\���̂��쐬���܂��B�eTYPE ������́A '.'�A'()'�A '{}'�̂����ꂩ��
% �Ȃ���΂Ȃ�܂���B �Ή�����SUBS �����́A('.'�^�C�v�ɑ΂��Ă�)
% �t�B�[���h���A�܂��́A('()'�A��'{}'�̃^�C�v�ɑ΂��Ă�)�C���f�b�N�X
% �x�N�g�����܂ރZ���z��̂����ꂩ�łȂ���΂Ȃ�܂���B�o��S�́A����
% �t�B�[���h���܂ލ\���̔z��ł�:
%
%    type -- �T�u�X�N���v�g�^�C�v '.'�A'()'�A'{}'
%    subs -- ���ۂ̃T�u�X�N���v�g�l 
%            (�C���f�b�N�X�x�N�g���̃Z���z��܂��̓����o�[��)
%
% ���Ƃ��΁A�V���^�b�N�X
%
%       B = A(i,j).field
%
% �ɓ����ȃp�����[�^�t��SUBSREF�́A���̃X�e�[�g�����g���g���܂��B
%
%       S = substruct('()',{i j},'.','field');
%       B = subsref(A,S);
%
% ���l�ɁA
%
%       subsref(A, substruct('()',{1:2, ':'}))  performs  A(1:2,:)
%       subsref(A, substruct('{}',{1 2 3}))     performs  A{1,2,3}.
%
% �Q�l�F SUBSREF, SUBSASGN.



%       Copyright 1984-2004 The MathWorks, Inc. 
