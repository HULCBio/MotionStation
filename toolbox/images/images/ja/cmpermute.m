% CMPERMUTE    �J���[�}�b�v���̃J���[�̍Ĕz��
% [Y,NEWMAP] = CMPERMUTE(X,MAP) �́AMAP ���̃J���[�������_���ɕ��ёւ���
% �V�����J���[�}�b�v NEWMAP ���쐬���܂��BCMPERMUTE �́AX �̒��̒l���A�C
% ���f�b�N�X�ƃJ���[�}�b�v�Ԃ̑Ή����ێ����Ȃ���ύX���A���̌��ʂ� Y ��
% �o�͂��܂��B�C���[�W Y �Ƃ���Ɋ֘A����J���[�}�b�v NEWMAP �́AX �� 
% MAP �ō쐬�����C���[�W�Ɠ����C���[�W���쐬���܂��B
% 
% [Y,NEWMAP] = CMPERMUTE(X,MAP,INDEX) �́A���Ԃ�ݒ肵���s��(SORT ��2��
% �ڂ̏o�͈���)���g���āA�V�����J���[�}�b�v�ɃJ���[�̏��Ԃ��`���܂��B
% 
% ���Ƃ��΁A�P�x���g���āA�J���[�}�b�v�̏��Ԃ����߂܂��B
% 
%   ntsc = rgb2ntsc(map);
%   [dum,index] = sort(ntsc(:,1));
%   [Y,newmap] = cmpermute(X,map,index);
% 
% �N���X�T�|�[�g
% -------------
% ���̓C���[�W X �́Auint8�A�܂��́Adouble �̂�����̃N���X���T�|�[�g��
% �Ă��܂��BY �́AX �Ɠ����N���X�̔z��Ƃ��ďo�͂���܂��B
% 
% ���
% -------
% �P�x���g���āA�J���[�}�b�v�̏��Ԃ����߂܂��B
%
%       load trees
%       ntsc = rgb2ntsc(map);
%       [dum,index] = sort(ntsc(:,1));
%       [Y,newmap] = cmpermute(X,map,index);
%       imshow(X,map), figure, imshow(Y,newmap)
%
% �Q�l�FRANDPERM, SORT.



%   Copyright 1993-2002 The MathWorks, Inc.  
