% STREAMPARTICLES �́A�X�g���[�����q�̕\�����s���܂��B
% 
% STREAMPARTICLES(VERTICES) �́A�x�N�g����̃X�g���[�����q��`�悵�܂��B
% �X�g���[�����q�́A�ʏ�A����}�[�J�ŕ\���A�X�g���[�����C���̑��x��
% �ʒu�Ŏ������Ƃ��ł��܂��BVERTICES �́A(STREAM2 �� STREAM3 �ō쐬����)
% 2�����A3�����̒��_�̃Z���z��ł��B
%
% STREAMPARTICLES(VERTICES, N) �́A�X�g���[�����q��`�悷�鐔�� N ��
% �g���Đݒ肵�܂��B'ParticleAlignment' �v���p�e�B�́AN ���ǂ̂悤�ɉ���
% ���邩���R���g���[�����܂��B'ParticleAlignment' �� 'off' (�f�t�H���g)�ŁA
% N��1�ȏ�̏ꍇ�́A�ߎ��I�ɁAN �̗��q�̓X�g���[�����C�����_�ɓn��A
% ���Ԋu�ɕ`�悳��܂��BN ��1�ɓ��������������ꍇ�́AN �̓I���W�i����
% �X�g���[�����_�̐����炠�镔��(����)�݂̂��g�p���܂��B���Ƃ��΁AN ��
% 0.2�̏ꍇ�́A��20%�̒��_�����g���܂��BN �́A�`�悷�闱�q�̐��̏����
% �ݒ肵�܂��B���q�̎��ۂ̐��́A2�̃x�L��̌^�� N ���狁�܂�܂��B
% 'ParticleAlignment' �� 'on' �̏ꍇ�́AN �́A���_�S�̂����ԃX�g���[��
% ���C���Ɋւ��āA�����Ŏg�p���闱�q�̐������肵�܂��B���Ȃ킿�A����
% �X�g���[�����C����̊Ԋu�Ƃ��āA���̒l��ݒ肵�܂��B�f�t�H���g��1�ł��B
%
% STREAMPARTICLES(... 'NAME1',VALUE1,'NAME2',VALUE2,...) �́A�v���p�e�B��
% �Ƃ���ɐݒ肵���l���g���āA�X�g���[�����q���R���g���[�����܂��B�ݒ�
% ���Ă��Ȃ��v���p�e�B�ɂ́A�f�t�H���g�l���g���܂��B�v���p�e�B���̐ݒ�
% �ɂ́A�啶���A�������̋�ʂ͍s���܂���B
%
% STREAMPARTICLES PROPERTIES(�X�g���[�����q�̃v���p�e�B)
% 
% Animate           - �X�g���[�����q�̉^�� [ �񕉂̐��� ]
% �@�@�@�@�@�@�@�@�@�@�X�g���[�����q���A�j���[�V��������񐔁B�f�t�H���g
%                     ��0�ŁA�A�j���[�V�������s���܂���BInf �́ACtrl-C 
%                     �Œ�~����܂ŁA�A�j���[�V�����͑����܂��B
%
% FrameRate         - �P�ʎ���(�b�P��)������̃A�j���[�V�����̃t���[����
%                     [ �񕉂̐��� ] 
%                     �A�j���[�V�����ł̒P�ʎ��Ԃ�����̃t���[�������w��
%                     ���܂��B�f�t�H���g�́AInf �ŁA�A�j���[�V�������\
%                     �Ȍ��荂���ɂ��܂��B���ӁF�t���[����́A�A�j���[�V
%                     �����̃X�s�[�h�A�b�v�ɂ͂Ȃ�܂���B
%
% ParticleAlignment - �X�g���[�����C�����g���āA���q������ 
%                     [ on | {off} ] 
%                     ���̃v���p�e�B�� 'on' �ɐݒ肷��ꍇ�́A�X�g���[��
%                     ���C���̍ŏ��̕����ɗ��q��`�悵�܂��B���̃v���p�e�B
%                     �́AN ���ǂ̂悤�ɉ��߂��邩���R���g���[�����܂��B
% 
% �܂��A�������̃��C���v���p�e�B�Ƃ���Ɋ֘A�����l�ɁA'erasemode' �܂�
% �� 'marker' ���g�p���邱�Ƃ��ł��܂��B���ɁASTREAMPARTICLES �Őݒ�
% ���郉�C���v���p�e�B�̃f�t�H���g�������܂��B�����́A�v���p�e�B��/�l��
% ���[�U���ݒ肷�邱�Ƃɂ��A���������邱�Ƃ��ł��܂��B
%
%   �v���p�e�B��        �l
%   ------------        --
%   'EraseMode'        'xor'
%   'LineStyle'        'none'
%   'Marker'           'o'
%   'MarkerEdgeColor'  'none'
%   'MarkerFaceColor'  'red'
%
% STREAMPARTICLES(H,...) �́ALINE �I�u�W�F�N�g H ���g���āA�X�g���[��
% ���q��`�悵�܂��B
%
% STREAMPARTICLES(AX,...) �́AGCA�̑����AX�Ƀv���b�g���܂��BH���w�肷��
% �ꍇ�́A���̃I�v�V�����́A��������܂��B
%
% H = STREAMPARTICLES(...) �́ALINE �I�u�W�F�N�g�̃n���h���ԍ����x�N�g��
% �Ƃ��ďo�͂��܂��B
%
% ��� 1:
% 
%      load wind
%      [sx sy sz] = meshgrid(80, 20:1:55, 5);
%      verts = stream3(x,y,z,u,v,w,sx,sy,sz);
%      sl = streamline(verts);
%      iverts = interpstreamspeed(x,y,z,u,v,w,verts,.025);
%      axis tight; view(30,30); daspect([1 1 .125])
%      set(gca, 'drawmode', 'fast')
%      camproj perspective; box on
%      camva(44); camlookat; camdolly(0,0,.4, 'f');
%      h = line; 
%      streamparticles(h, iverts, 35, 'animate', 10, ...
%                      'ParticleAlignment', 'on');
%
% ��� 2:
% 
%      load wind
%      daspect([1 1 1]); view(2)
%      [verts averts] = streamslice(x,y,z,u,v,w,[],[],[5]); 
%      sl = streamline([verts averts]);
%      axis tight off;
%      set(sl, 'linewidth', 2, 'color', 'r', 'vis', 'off')
%      iverts = interpstreamspeed(x,y,z,u,v,w,verts,.05);
%      set(gca, 'drawmode', 'fast', 'position', [0 0 1 1])
%      set(gcf, 'color', 'k')
%      h = line; 
%      streamparticles(h, iverts, 200, ...
%                      'animate', 100, 'framerate',40, ...
%                      'markers', 10, 'markerf', 'y');
%
% �Q�l�FINTERPSTREAMSPEED, STREAMLINE, STREAM3, STREAM2.


%   Copyright 1984-2002 The MathWorks, Inc. 
