function results = main_SI_ToM(subject,run, list_number, params, experiment)
% Present auditory and visual stimuli. The first two stimuli are for
% practice only (not included in the analysis).

% Trial structure:
% 10s story ->
% 4s response ->
% 12s fixation

%% Setup
% Add_Psych;
% For tests or practice, use:
% Screen('Preference', 'SkipSyncTests', 1);
% In the scanner, use:
% Screen('Preference', 'SkipSyncTests', 0);
Screen('Preference', 'SkipSyncTests', 1);

% Create output file
file_name = sprintf('log_subject_%i_run_%i.txt', subject, run);
output_dir = sprintf('Output_%s', experiment);
fid = fopen(fullfile('..', output_dir, file_name), 'w');
fprintf(fid,'Trial\tCond\tStoryStart\tQuestionStart\tFixStart\tStoryFN\tQuestionFN\tSjtChoice\tRT\n');
% Initialize
warning off
HideCursor

% FOR DEBUG ONLY (COMMENT OUT IF NOT DEBUGGING)
% PsychDebugWindowConfiguration([0],[0.5])
% --------------------------------------------

% window properties and stimuli
rect = params.rect;
win = Screen('OpenWindow', 0, params.screen_color, rect);
stimuli = load_stimuli(win, run, list_number, params, experiment);
Screen(win, 'TextSize', params.fixation_size);
intro_img_path = sprintf('../Intro_%s.jpg', experiment);
intro_img_read = imread(intro_img_path);
intro_img = Screen('MakeTexture', win, intro_img_read, [], [], [], [], 0);
Screen('DrawTexture', win, intro_img, [], [], 0);
% Full screen: Screen('DrawTexture', win, intro_img, [], params.rect, 0);
Screen('Flip', win);

%% Wait for a starting trigger ('t') from the MRI
escKey = KbName('esc');
t_pressed = false;
while ~t_pressed
    [~, ~, keyCode] = KbCheck;
    if any(keyCode([KbName('5'),KbName('5%')]))
        t_pressed = true;
    elseif keyCode(escKey)
        DisableKeysForKbCheck([]);
        Screen('CloseAll');
        return
    end
end
grandStart = tic;
DisableKeysForKbCheck(KbName('5')); % Ignores repeating t's from the MRI. Otherwise, psychtoolbox crashes
DisableKeysForKbCheck(KbName('5%'));

%% Wait several TRs before start with fixation mark
% Define keys and draw fixation
middleKey2 = KbName('3'); leftKey = KbName('1');
middleKey1 = KbName('2'); rightKey = KbName('4');
subject_responses = cell(stimuli.num_trials, 1);
%[~, ~, ~, fixation_cache, ~] = DrawFormattedText2('+', 'win', win, 'sx', 'center', 'sy', 'center', 'xalign', 'center', 'yalign', 'center', 'baseColor', params.fixation_color);
% DrawFormattedText2(fixation_cache);
DrawFormattedText(win, '+', 'center', 'center', params.fixation_color);
Screen('Flip',win);

% wait a few TRs before starting
% The first two stimuli are practice only and will be excluded
while toc(grandStart) < params.beginning_lag - params.practice_duration
end

%% Begin experiment
for i = 1:stimuli.num_trials
    trial = tic;
    log_row = []; curr_row = [];
    log_row{1} = i;
    log_row{2} = stimuli.condition_name{i};
    log_row{3} = toc(grandStart);
    choice_str = '-'; subject_responses{i, 1, 1} = '-'; subject_responses{i, 2, 1} = -999; cnt_presses = 0;
    %% Present Story
    Screen('DrawTexture', win, stimuli.visual(i).image, [], params.visualCoords);
    Screen('Flip',win);
    % wait for the story presentation time
    while toc(trial) < params.story_duration
    end
    
    %% Present Question
    Screen('DrawTexture', win, stimuli.visual(i).question, [], params.visualCoords);
    Screen('Flip',win);
    log_row{4} = toc(grandStart);
    
    %% Wait for response
    rt = tic;
    while toc(trial) < params.visual_duration
        press_event = false;
        [~, ~, keyCode] = KbCheck;
        if any(keyCode([middleKey2,KbName('3#')]))
            press_event = true; choice_str = '3';
        elseif any(keyCode([leftKey,KbName('1!')]))
            press_event = true; choice_str = '1';                    
        elseif any(keyCode([middleKey1,KbName('2@')]))
            press_event = true; choice_str = '2';
        elseif any(keyCode([rightKey,KbName('4$')]))
            press_event = true; choice_str = '4';
        elseif keyCode(escKey)
            DisableKeysForKbCheck([]);
            Screen('CloseAll');
            ShowCursor
            return
        end           

        if press_event
            if cnt_presses > 0
                if ~strcmp(subject_responses{i,1,cnt_presses}, choice_str)
                    cnt_presses = cnt_presses + 1;
                    subject_responses{i, 1, cnt_presses} = choice_str;
                    subject_responses{i, 2, cnt_presses} = toc(rt);
                end
            else
                cnt_presses = cnt_presses + 1;
                subject_responses{i, 1, cnt_presses} = choice_str;
                subject_responses{i, 2, cnt_presses} = toc(rt);
            end
        end

    end

        %% Fixation
        log_row{5} = toc(grandStart);
        % Show subject's choice on the top-right corner
        Screen(win, 'TextSize', 30);
        DrawFormattedText(win, choice_str, 0.95*rect(3), 0.05*rect(4), params.fixation_color)
        % Show fixation
        Screen(win, 'TextSize', params.fixation_size);
        % DrawFormattedText2(fixation_cache);
        DrawFormattedText(win, '+', 'center', 'center', params.fixation_color);
        Screen('Flip',win);

        while toc(grandStart) < stimuli.end_trial(i) % Wait
        end
        log_row{6} = stimuli.visual(i).image_file_name;
        log_row{7} = stimuli.visual(i).question_file_name;
        log_row{8} = subject_responses{i, 1, 1};
        log_row{9} = subject_responses{i, 2, 1};

    curr_row = sprintf('%i\t%s\t%0.6f\t%0.6f\t%0.6f\t%s\t%s\t%s\t%0.6f', log_row{1}, log_row{2}, log_row{3}, log_row{4}, log_row{5}, log_row{6}, log_row{7}, log_row{8}, log_row{9});
    fprintf(fid,'%s\n', curr_row);
    
end

last_lag = tic;
while toc(last_lag) < params.last_lag
    if toc(last_lag) < params.last_lag
        DrawFormattedText(win, '+', 'center', 'center', params.fixation_color);
        Screen('Flip',win);
    end
end

%% save data
toc(grandStart)
DisableKeysForKbCheck([]);
Screen('CloseAll');
% Remove_Psych;

results.subject_responses = subject_responses;
PsychPortAudio('Close');
fclose(fid); % close log file

ShowCursor

end