% IMARGIN   ���}���g���āA�Q�C���]�T�ƈʑ��]�T���o��
%
% [Gm,Pm,Wcg,Wcp] = IMARGIN(MAG,PHASE,W) �́ABode �����̃Q�C���ƈʑ��A
% ���g���x�N�g�� MAG�APHASE�AW ��^���āA���`�V�X�e������Q�C���]�T Gm ��
% �ʑ��]�T Pm �A�֘A�������g���AWcg��Wcp ���o�͂��܂��BIMARGIN �́A���`
% �X�P�[���ŃQ�C���l���A�x�P�ʂňʑ��l���l���Ă��܂��B
%
% ���ӂ̈�����ݒ肵�Ȃ� IMARGIN(MAG,PHASE,W) �ꍇ�A�������Ń}�[�N�t��
% ���ꂽ�Q�C���ƈʑ��]�T������ Bode ������\�����܂��B
%
% IMARGIN �́A�A���V�X�e���A���U�V�X�e�����Ɏg�p�\�ł��B�^�̃Q�C���]�T
% �ƈʑ��]�T�ɋߎ����邽�߂ɁA���g���_�Ԃɓ��}���g�p���܂��B�V�X�e�����A
% LTI���f���̏ꍇ�AMARGIN ���g���āA��萸�x�̍������̂��o�͂��邱�Ƃ�
% �ł��܂��B
%
% IMARGIN �̗��F
%     [mag,phase,w] = bode(a,b,c,d);
%     [Gm,Pm,Wcg,Wcp] = imargin(mag,phase,w)
%
% �Q�l�FBODE, MARGIN, ALLMARGIN.


%   Clay M. Thompson  7-25-90
%   Revised A.C.W.Grace 3-2-91, 6-21-92
%   Revised A.Potvin 10-1-94
%   Revised P. Gahinet 10-99
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.3.4.1 $  $Date: 2003/06/26 16:04:15 $
