% Run
clear all; close all; clc

addpath('functions')

%% Experiment, Run and Subject Details
experiment = choosedialog('Experiment', 'Choose an experiment:', {'Shapes', 'Flanker',  'Animals', 'ToM'});
answer = inputdlg({'Subject name', 'list', 'Run number (-1 for practice)'}, 'Input', 1);
subject = str2double(answer{1});
list_number = str2double(answer{2});
run = str2double(answer{3});
filename = sprintf('Subject_%i_run_%i.mat', subject, run);
output_dir = sprintf('Output_%s', experiment);
% Check if the subject number already exists
A = exist(fullfile('..', output_dir, filename), 'file');
if A == 2
    msgbox(sprintf('File already exists : %s\nPlease change subject number or run', filename));
    error('Please change subject number or run')
end
params = load_params(experiment, run);

%% Run paradigm
switch experiment
    case 'ToM'
        results = main_SI_ToM(subject, run, list_number, params, experiment);
    otherwise
        results = main_SI_grand_start(subject, run, list_number, params, experiment);
end
results.output_filename = fullfile('..', output_dir, filename);

%% Save results
save(fullfile('..', output_dir, filename), 'results');
fprintf('Results saved into %s\n', results.output_filename);
fclose('all');