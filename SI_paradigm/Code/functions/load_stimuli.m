function stimuli = load_stimuli(win, run, list_number, params, experiment)
% This function loads images and audio files into a struct of stimuli

%% List and run details
list2str = ['a','b','c','d','e','p']; %The last element is practice
% If the run # is -1, use the practice list
if run == -1
    run = length(list2str);
end

%% Paths
visual_dir = sprintf('%s_visual', experiment);
path2stimuli_visual = fullfile('..', 'Stimuli', visual_dir);
% if the experiment has audio, set the paths for auditory stimuli
if params.enable_audio
    audio_dir = sprintf('%s_audio', experiment);
    path2stimuli_audio = fullfile('..', 'Stimuli', audio_dir);
end
path2excel = fullfile('..', 'Stimuli');
lists_tab = sprintf('List%d_%s', list_number, list2str(run));

%% Extract stimuli names from Excel
excel_name = sprintf('%s_stimuli.xlsx', experiment);
[audio_numbers, visual_file_name, ~] = xlsread(fullfile(path2excel, excel_name), lists_tab);
if params.enable_audio
    audio_files_info = dir(fullfile(path2stimuli_audio, '*.wav'));
    audio_files_names = extractfield(audio_files_info, 'name');
end

%% Load lists
lists_file_name = strcat(experiment, '_lists.xlsx');
lists_path = fullfile(path2excel, lists_file_name);
[list_num_data, list_txt_data, ~] = xlsread(lists_path, lists_tab);
[optseq_list.timing, optseq_list.condition_number, optseq_list.stimulus_duration] = feval(@(x) x{:}, {list_num_data(:,1), list_num_data(:,2), list_num_data(:,3)});
optseq_list.condition_name = list_txt_data(:,1);
stimuli.num_trials = length(optseq_list.condition_number); % Trials including NULL conditions

%% Build stimuli struct for output
switch experiment
    case 'Shapes'
        cnt.HelekAll = 0; cnt.HelekSome = 0; cnt.HelekNone = 0;
        cnt.KolAll = 0; cnt.KolSome = 0; cnt.KolNone = 0;
    case 'Animals'
        cnt.Some = 0; cnt.All = 0; cnt.Filler = 0;
    case 'Flanker'
        cnt.Congruent = 0; cnt.Incongruent = 0;
end
token_number_cnt = 0; % Omit NULL conditions from counting
for i = 1:stimuli.num_trials
    stimuli.condition_name{i} = optseq_list.condition_name{i};
    if ~strcmp(optseq_list.condition_name{i}, 'NULL')
        token_number_cnt = token_number_cnt + 1;
        curr_condition_name = optseq_list.condition_name{i};
        cnt.(curr_condition_name) = cnt.(curr_condition_name) + 1;
        % load AUDITORY
        if params.enable_audio
            audio_number = audio_numbers(token_number_cnt);
            stimuli.auditory(i).auditori_file_name = audio_files_names{audio_number};
            stimuli.auditory(i).file_name = fullfile(path2stimuli_audio, stimuli.auditory(i).auditori_file_name);
            [stimuli.auditory(i).y, stimuli.auditory(i).fs] = audioread(stimuli.auditory(i).file_name);
            stimuli.auditory(i).y = stimuli.auditory(i).y(:,1);
            stimuli.auditory(i).length = 1000*length(stimuli.auditory(i).y)/stimuli.auditory(i).fs; % Duration in ms
        end

        % load VISUAL
        switch experiment
            case 'Animals'
                prefix = strcat(list2str(run),'_'); % specific prefix for 'animals' picture names
            otherwise
                    prefix = '';
        end
        stimuli.visual(i).image_file_name = strcat(prefix,visual_file_name{token_number_cnt}, '.jpg');
        stimuli.visual(i).image = imread(fullfile(path2stimuli_visual, stimuli.visual(i).image_file_name));
        stimuli.visual(i).image = Screen('MakeTexture', win, stimuli.visual(i).image);
    else % put empty visuals/auditories for NULL conditions
        stimuli.auditory(i).y = zeros(round(44100 * params.audio_duration * 0.9), 1);
        stimuli.visual(i).image = [];
    end
    stimuli.duration(i) = optseq_list.stimulus_duration(i);
end

% Load ping
if params.enable_audio
    stimuli.ping.auditori_file_name = 'ping.wav';
    stimuli.ping.file_name = fullfile('..', 'Stimuli', stimuli.ping.auditori_file_name);
    [stimuli.ping.y, stimuli.ping.fs] = audioread(stimuli.ping.file_name);
    stimuli.ping.y = stimuli.ping.y(:,1);
    stimuli.ping.length = 1000*length(stimuli.ping.y)/stimuli.ping.fs; % Duration in ms
end
    
stimuli.list = optseq_list;
stimuli.first_stim_timing = params.beginning_lag - params.practice_duration;
stimuli.start_trial = stimuli.list.timing' + stimuli.first_stim_timing;
stimuli.end_trial = stimuli.start_trial + stimuli.duration;
end