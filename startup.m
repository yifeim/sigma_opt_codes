function [] = startup()


  mypath = pwd;

  disp('starting from root ...')

  % lib_extern
  cd lib_extern/;
  startup;
  cd(mypath);

  % lib
  cd libsrc/;
  startup;
  cd(mypath);

  % core
  cd core/;
  startup;
  cd(mypath);
  
  % data
  cd data/;
  addpath(pwd);
  cd(mypath);



  % set command window format
  format compact
  format short g

  % turn beep on
  beep on

  set(0, 'DefaultAxesBox', 'on');
  set(0, 'DefaultTextFontSize', 14);
  set(0, 'DefaultAxesFontSize', 16);

  setenv EDITOR vim;
  
%   diary on

  % set random state AT THE VERY LAST so that toolbox packages won't overwrite
  rng('default')
  rng('shuffle')
  rng_state = rng()

%   diary off

  % disp('starting...')
  % 
  % setenv('EDITOR','vim');
  % mypath = pwd;
  % cd('../libsrc/gpml');
  % startup;
  % cd(mypath);
  % 
  % % set random state
  % rand ('state', sum(100*clock));
  % randn('state', sum(100*clock));
  % 
  % % set command window format
  % format compact
  % format short g
  % 
  % % turn beep on
  % beep on
  % 
  % % set some other default values
  % % set(0, 'RecursionLimit', 50);
  % % set(0, 'DefaultFigurePaperType', 'A4');
  % % set(0, 'DefaultFigureWindowStyle', 'normal');
  % set(0, 'DefaultAxesBox', 'on');
  % set(0, 'DefaultTextFontSize', 14);
  % set(0, 'DefaultAxesFontSize', 16);
  % % set(0, 'DefaultUicontrolFontSize', 8);
  % % recycle('off');
  % % warning on all
  % % warning on backtrace
  % 
  % setenv EDITOR vim;
  % 
  % %dependents
  % subdirs = ls('-d','*/');
  % while ~isempty( sscanf(subdirs, '%s/%s') ) 
  %   [subdir, subdirs] = strtok(subdirs);
  %   addpath([pwd, '/', subdir]);
  % end
  % % library
  % addpath(genpath([mypath,'/../libsrc/']));
  % % data
  % addpath([mypath,'/../data/']);
  % addpath('/auton/data/graphGP/assorted/');
  % 
  % % clearvars
  % 
