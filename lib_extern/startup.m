function [] = startup()

disp('starting lib_extern');

mypath = pwd;

% export_fig
disp('export_fig');
cd export_fig;
addpath(pwd);
cd(mypath);

% IsomapR1
disp('IsomapR1');
cd IsomapR1;
addpath(pwd);
cd(mypath);


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
