function [] = startup()

disp('starting lib_extern');

mypath = pwd;

% gpml
disp('adding gpml');
cd gpml2;
startup;
cd(mypath);

% SFO
disp('sfo');
cd sfo;
addpath(pwd);
cd(mypath);
