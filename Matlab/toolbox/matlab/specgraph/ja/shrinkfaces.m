% SHRINKFACES   �p�b�`�̖ʂ̃T�C�Y�̍팸
%
% SHRINKFACES(P, SF) �́A�p�b�` P�̖ʂ̖ʐς��k���W�� SF ����ɏk����
% �܂��BSF ��0.6�̏ꍇ�A�e�X�̖ʂ͌��̖ʐς�60%�ɏk������܂��B�p�b�`��
% ���L����Ă��钸�_���܂ޏꍇ�A�팸����O�ɁA���_�����L���Ȃ��悤��
% �쐬����܂��B
% 
% NFV = SHRINKFACES(P, SF) �́A�ʂƒ��_���o�͂��܂����A�p�b�` P�� Faces
% �v���p�e�B�� Vertices �v���p�e�B�͐ݒ肵�܂���B�\���� NFV �́A�V�K��
% �ʂ���ђ��_���܂݂܂��B
% 
% NFV = SHRINKFACES(FV, SF) �́A�\���� FV ����ʂƒ��_���g�p���܂��B
%
% SHRINKFACES(P) �܂��� SHRINKFACES(FV) �́A�k���W����.3�Ɖ��肵�܂��B
% 
% NFV = SHRINKFACES(F, V, SF) �́A�z�� F ����� V ���̖ʂ���ђ��_��
% �g�p���܂��B
% 
% [NF, NV] = SHRINKFACES(...) �́A�\���̂̑����2�̔z����̖ʂ����
% ���_���o�͂��܂��B
% 
% ���:
%      [x y z v] = flow;
%      [x y z v] = reducevolume(x,y,z,v, 2);
%      fv = isosurface(x, y, z, v, -3);
%      subplot(1,2,1)
%      p = patch(fv);
%      set(p, 'facecolor', [.5 .5 .5], 'EdgeColor', 'black');
%      daspect([1 1 1]); view(3); axis tight
%      title('Original')
%      subplot(1,2,2)
%      p = patch(shrinkfaces(fv, .2)); % �I���W�i���� 20% �܂Ŗʂ��팸
%      set(p, 'facecolor', [.5 .5 .5], 'EdgeColor', 'black');
%      daspect([1 1 1]); view(3); axis tight
%      title('After Shrinking')
%   
% �Q�l�FISOSURFACE, ISONORMALS, ISOCAPS, SMOOTH3, SUBVOLUME, 
%       REDUCEVOLUME, REDUCEPATCH.


%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.9.4.1 $  $Date: 2004/04/28 02:06:12 $
