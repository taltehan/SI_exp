function stimuli = load_stimuli_ToM(win, run, list_number, params, experiment)
% This function loads images into a struct of stimuli

%% List and run details
list2str = ['a','b','c','d','e','p']; %The last element is practice
% If the run # is -1, use the practice list
if run == -1
    run = length(list2str);
end

%% Paths
visual_dir = sprintf('%s_visual', experiment);
path2stimuli_visual = fullfile('..', 'Stimuli', visual_dir);
path2excel = fullfile('..', 'Stimuli');
lists_tab = sprintf('List%d_%s', list_number, list2str(run));

%% Extract stimuli names from Excel
excel_name = sprintf('%s_stimuli.xlsx', experiment);
stimuli_names = readtable(fullfile(path2excel, excel_name), 'Sheet', lists_tab, 'ReadVariableNames', false);
visual_file_name = stimuli_names{:,1};
question_file_name = stimuli_names{:,2};

%% Load lists
lists_file_name = strcat(experiment, '_lists.xlsx');
lists_path = fullfile(path2excel, lists_file_name);
list_data = readtable(lists_path, 'Sheet', lists_tab, 'ReadVariableNames', false);
lists.condition_name = list_data{:,1};
stimuli.num_trials = length(lists.condition_name);
lists.stimulus_duration = repmat(params.story_duration, 1, stimuli.num_trials);
lists.timing = cumsum(lists.stimulus_duration);

%% Build stimuli struct for output
token_number_cnt = 0; % Omit NULL conditions from counting
for i = 1:stimuli.num_trials
    stimuli.condition_name{i} = lists.condition_name{i};
    token_number_cnt = token_number_cnt + 1;
    % load story
    stimuli.visual(i).image_file_name = strcat(visual_file_name{token_number_cnt}, '.jpg');
    stimuli.visual(i).image = imread(fullfile(path2stimuli_visual, stimuli.visual(i).image_file_name));
    stimuli.visual(i).image = Screen('MakeTexture', win, stimuli.visual(i).image);
    stimuli.duration(i) = lists.stimulus_duration(i);
    % load question
    stimuli.visual(i).question_file_name = strcat(question_file_name{token_number_cnt}, '.jpg');
    stimuli.visual(i).question = imread(fullfile(path2stimuli_visual, stimuli.visual(i).question_file_name));
    stimuli.visual(i).question = Screen('MakeTexture', win, stimuli.visual(i).question);
end

% Create stimuli struct
stimuli.list = lists;
stimuli.first_stim_timing = params.beginning_lag - params.practice_duration;
stimuli.start_trial = stimuli.list.timing' + stimuli.first_stim_timing;
stimuli.end_trial = stimuli.start_trial + stimuli.duration;
end