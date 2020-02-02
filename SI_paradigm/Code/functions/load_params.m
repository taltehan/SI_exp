function params = load_params(experiment, run)
%% General params
params.TR = 2; %in sec
%Check if the experiment requires audio
audio_dir_name = strcat(experiment,'_audio');
params.enable_audio = exist(fullfile('..', 'Stimuli', audio_dir_name), 'dir');

%% Time durations
% beginning and end lags
params.beginning_lag = 6*params.TR;
% On practice runs, reduce the end lag
if run == -1
    params.last_lag = params.TR;
else
    params.last_lag = 3*params.TR;
end

%audio
params.audio_duration = params.TR; %s

% fixation
switch experiment
    case 'ToM'
        params.fixation_duration = 12; %s
    otherwise
        params.fixation_duration = 0.3; %s
end

% visual
switch experiment
    case 'Flanker'
        params.visual_duration = params.TR - params.fixation_duration; %s
    case 'ToM'
        params.story_duration = params.TR * 5;
        params.question_duration = params.TR * 2;
        params.visual_duration = params.story_duration + params.question_duration;
    otherwise
        params.visual_duration = 2*params.TR - params.fixation_duration; %s
end

% practice
switch experiment
    case 'ToM'
        params.practice_duration = 0;
    otherwise
        params.practice_duration = 2*(params.visual_duration + params.fixation_duration);
end

%% Visual Presentation
% for fullscreen:
% rect = get(0, 'ScreenSize');
% params.rect = [0 0 rect(3:4)];
% If fullscreen doesn't work:
params.rect = [0 0 1920 1080];
screenW = params.rect(3);
screenH = params.rect(4);
switch experiment
    case {'Flanker', 'ToM'}
        visualW = screenW/2.5;
        visualH = screenH/2.5;
    otherwise
        visualW = screenW/2;
        visualH = screenH/1.5;
end
visualCoords = [0 0 0 0];
visualCoords(1) = (screenW-visualW)/2;
visualCoords(2) = (screenH-visualH)/2;
visualCoords(3) = visualCoords(1)+visualW;
visualCoords(4) = visualCoords(2)+visualH;
params.visualCoords = visualCoords;

% Fixation properties
switch experiment
    case 'Flanker'
        params.screen_color = [231 229 230]; % gray
        params.fixation_color = [0 0 0]; % black
    case 'ToM'
        params.screen_color = [0 0 0];
        params.fixation_color = [0 0 0];
    otherwise
        params.screen_color = [0 0 0];
        params.fixation_color = [255 255 255]; % white
end
fixation_ratio = 3200/85;
params.fixation_size = params.rect(3)/fixation_ratio;

end
