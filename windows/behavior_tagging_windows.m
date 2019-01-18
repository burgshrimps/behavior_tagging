create_gui()

function create_gui
    %% Load video 
    [filename, pathname] = uigetfile('*.avi');
    file = strcat(pathname ,filename);
    FPS = input('Enter video FPS: ');
    
    %% Create and open video player window 
    handle = implay(file); % movie player
    controls = handle.DataSource.Controls; % control unit to acces movie player parameters
    set(findall(0,'tag','spcui_scope_framework'),'position',[10 150 700 550]); % adjust size of user player
    
    %% Get number of total frames and length of video 
    gotoEnd(controls);
    numFrames = controls.CurrentFrame;
    gotoStart(controls);
    
    %% Set up timer to update current frame anf time display %
    lastFrame = 1; % used to updated the slider position every 10s to minimize video lagging 
    timeIt();
    
    %% UI Figure %%
    f = figure('Visible','off','Position',[730,150,700,240]); % canvas for user interface
    
    %% Slider %%
    slider = uicontrol('style','slider','position',[10 205 680 20],'min', 0, 'max', numFrames, 'SliderStep', [1/(numFrames-1) 1/(numFrames-1)]);
    addlistener(slider, 'Value', 'PostSet', @slider_callback); % listener makes it possible to jumpTo corresponding video frame after slider movement
    
    %% Video information display %%
    currTimeTxt = uicontrol('style','text','position',[70 175 50 20],'String', '00:00:000');
    currFrameTxt = uicontrol('style','text','position',[70 160 50 20],'String', '1');
    totalTimeTxt = uicontrol('style','text','position',[590 175 50 20],'String', num2time(numFrames));
    totalFrameTxt = uicontrol('style','text','position',[590 160 50 20],'String', num2str(numFrames));
    
    %% Playback buttons %%
    playbutton = uicontrol('Style', 'pushbutton', 'String', 'Play', 'Position', [300,165,50,35], 'Callback', @playbutton_callback);
    pausebutton = uicontrol('Style', 'pushbutton', 'String', 'Pause', 'Position', [350,165,50,35], 'Callback', @pausebutton_callback);
    fwd1button = uicontrol('Style', 'pushbutton', 'String', '>>', 'Position', [400,165,40,35], 'Callback', @fwd1button_callback);
    bwd1button = uicontrol('Style', 'pushbutton', 'String', '<<', 'Position', [260,165,40,35], 'Callback', @bwd1button_callback);
    fwd2button = uicontrol('Style', 'pushbutton', 'String', '>>>', 'Position', [440,165,40,35], 'Callback', @fwd2button_callback);
    bwd2button = uicontrol('Style', 'pushbutton', 'String', '<<<', 'Position', [220,165,40,35], 'Callback', @bwd2button_callback);
    startbutton = uicontrol('Style', 'pushbutton', 'String', 'toStart', 'Position', [170,165,50,35], 'Callback', @startbutton_callback);
    endbutton = uicontrol('Style', 'pushbutton', 'String', 'toEnd', 'Position', [480,165,50,35], 'Callback', @endbutton_callback);
    
    %% Playback speed control %%
    uicontrol('Style','text','position',[70 125 50 25],'String', 'Speed', 'FontWeight', 'bold');
    speed1button = uicontrol('Style', 'pushbutton', 'String', '1x', 'Position', [70,105,50,25], 'Callback', @speed1button_callback);
    speed2button = uicontrol('Style', 'pushbutton', 'String', '0.5x', 'Position', [70,80,50,25], 'Callback', @speed2button_callback);
    speed3button = uicontrol('Style', 'pushbutton', 'String', '0.25x', 'Position', [70,55,50,25], 'Callback', @speed3button_callback);
    
    %% Jump to frame / time control %%
    uicontrol('Style','text','position',[590 125 50 25],'String', 'Jump To', 'FontWeight', 'bold');
    jumpframeedit = uicontrol('Style', 'edit','String', '1', 'position', [580 105 70 25], 'Callback', @jumpframeedit_callback);
    jumptimeedit = uicontrol('Style', 'edit','String','00:00:000','position', [580 75 70 25], 'Callback', @jumptimeedit_callback);
    
    %% Behavior tagging %%
    B = zeros(3,1); % 3xn matrix to store behavior phases, 1 row identifier, second row start, third row stop
    uicontrol('Style','text','position',[225 125 50 25],'String', 'Phases', 'FontWeight', 'bold');
    uicontrol('Style','text','position',[150 100 50 25],'String', 'Sleep'); % identifier = 1
    uicontrol('Style','text','position',[150 75 50 25],'String', 'Run'); % identifier = 2
    uicontrol('Style','text','position',[150 50 50 25],'String', 'Sniff'); % identifier = 3
    uicontrol('Style','text','position',[150 25 50 25],'String', 'Eat'); % identifier = 4
    
    sleepstartbutton = uicontrol('Style', 'pushbutton', 'String', 'Start', 'Position', [200 105 50 25], 'Callback', @sleepstart_callback);
    sleepstopbutton = uicontrol('Style', 'pushbutton', 'String', 'Stop', 'Position', [250 105 50 25], 'Callback', @stop_callback);
    
    runstartbutton = uicontrol('Style', 'pushbutton', 'String', 'Start', 'Position', [200 80 50 25], 'Callback', @runstart_callback);
    runstopbutton = uicontrol('Style', 'pushbutton', 'String', 'Stop', 'Position', [250 80 50 25], 'Callback', @stop_callback);
    
    sniffstartbutton = uicontrol('Style', 'pushbutton', 'String', 'Start', 'Position', [200 55 50 25], 'Callback', @sniffstart_callback);
    sniffstopbutton = uicontrol('Style', 'pushbutton', 'String', 'Stop', 'Position', [250 55 50 25], 'Callback', @stop_callback);
    
    eatstartbutton = uicontrol('Style', 'pushbutton', 'String', 'Start', 'Position', [200 30 50 25], 'Callback', @eatstart_callback);
    eatstopbutton = uicontrol('Style', 'pushbutton', 'String', 'Stop', 'Position', [250 30 50 25], 'Callback', @stop_callback);
    
    %% Decision tagging %%
    uicontrol('Style','text','position',[400 125 100 25],'String', 'Timepoints', 'FontWeight', 'bold');
    uicontrol('Style','text','position',[400 100 100 25],'String', 'Stimulus');
    uicontrol('Style','text','position',[400 50 100 25],'String', 'Decision');
    
    T = zeros(2,1); % 2xn matrix to store important time points, first row identifier, second row timepoint as frame index
    stimpresbutton = uicontrol('Style', 'pushbutton', 'String', 'Mark', 'Position', [425 80 50 25], 'Callback', @stimpresbutton_callback); % identifier = 1
    decisionbutton = uicontrol('Style', 'pushbutton', 'String', 'Mark', 'Position', [425 30 50 25], 'Callback', @decisionbutton_callback); % identifier = 2
    
    %% Finish %%
    finishbutton = uicontrol('Style', 'pushbutton', 'String', 'Finish', 'Position', [580 30 70 25], 'Callback', @finishbutton_callback, 'BackgroundColor', [1 0 0]);
    
    f.Visible = 'on';
    %% Functions %%
    function slider_callback(source, eventdata)
        new_frame = get(eventdata.AffectedObject, 'Value');
        jumpTo(controls,round(new_frame));
    end

    function playbutton_callback(source, eventdata)
        play(controls);
    end

    function pausebutton_callback(source, eventdata)
        pause(controls);
    end

    function fwd1button_callback(source, eventdata)
        stepFwd(controls);
    end

    function bwd1button_callback(source, eventdata)
        stepBack(controls);
    end

    function fwd2button_callback(source, eventdata)
        jumpTo(controls, controls.CurrentFrame + FPS*10);
    end

    function bwd2button_callback(source, eventdata)
        jumpTo(controls, controls.CurrentFrame - FPS*10);
    end

    function startbutton_callback(source, eventdata)
        gotoStart(controls);
    end

    function endbutton_callback(source, eventdata)
        gotoEnd(controls);
    end

    function speed1button_callback(source, eventdata)
        changeFrameRate(controls,FPS);
    end

    function speed2button_callback(source, eventdata)
        changeFrameRate(controls,FPS*0.5);
    end

    function speed3button_callback(source, eventdata)
        changeFrameRate(controls,FPS*0.25);
    end

    function jumpframeedit_callback(source, eventdata)
        frame = get(source, 'String');
        jumpTo(controls, str2num(frame));
    end

    function sleepstart_callback(source, eventdata)
        B = [B [1; controls.CurrentFrame; -1]];
    end

    function runstart_callback(source, eventdata)
        B = [B [2; controls.CurrentFrame; -1]];
    end

    function sniffstart_callback(source, eventdata)
        B = [B [3; controls.CurrentFrame; -1]];
    end

    function eatstart_callback(source, eventdata)
        B = [B [4; controls.CurrentFrame; -1]];
    end

    function stop_callback(source, eventdata)
        B(3,end) = controls.CurrentFrame;
    end

    function stimpresbutton_callback(source, eventdata)
        T = [T [1; controls.CurrentFrame]];
    end

    function decisionbutton_callback(source, eventdata)
        T = [T [2; controls.CurrentFrame]];
    end

    function jumptimeedit_callback(source, eventdata)
        time = get(source, 'String');
        min = time(1:2);
        s = time(4:5);
        ms = time(7:9);
        frame = str2num(ms) * (FPS/1000) + str2num(s) * FPS + str2num(min) * (FPS*60);
        jumpTo(controls, frame);
    end

    function finishbutton_callback(source, eventdata)
        close(f);
        close(handle);
        
        B = B(:,2:end); % remove first column to remove initialization zeros
        T = T(:,2:end);
        
        fidB = fopen(strcat(pathname, '\', filename(12:24), '_behavior_phases_TS'),'w');
        fprintf(fidB, '%7s %10s %10s\r\n', 'Phase', 'Start', 'Stop');
        fprintf(fidB, '%7d %10d %10d\r\n', B);
        
        fidT = fopen(strcat(pathname, '\', filename(12:24), '_stim_decision_TS'),'w');
        fprintf(fidT, '%10s %10s\r\n', 'Marker', 'Timestamp');
        fprintf(fidT, '%10d %10d\r\n', T);
        
        B_colors = ['r', 'b', 'y', 'c']; % color vector for plot, each behavior category gets own color
        hold off; % close any plots that might be open
        ffig = figure;
        hold on;
        for i = 1:length(B(1,:))
            % stop index of phase is -1 per default and stays -1 in cases 
            % one has forgotten to press the stop button before starting 
            % a new phase
            if B(3,i) == -1
                continue
            else
                plot([B(2,i) B(3,i)], [1 1], 'Color', B_colors(B(1,i)));
            end
        end
        set(findall(gca, 'Type', 'Line'),'LineWidth',45); % make lines in plot thicker
        h = zeros(6, 1);
        h(1) = plot(NaN,NaN,'or');
        h(2) = plot(NaN,NaN,'ob');
        h(3) = plot(NaN,NaN,'oy');
        h(4) = plot(NaN,NaN,'oc');
        h(5) = plot(NaN,NaN,'om');
        h(6) = plot(NaN,NaN,'ok');
        legend(h, 'Sleep','Run','Sniff','Eat','Stim. Present.','Decision');
    
        xlabel('frame index')
        title('behavioral categorization over time')
        set(gca,'ytick',[]) % makes y-axes numbers disappear because not necessary
        
        T_colors = ['m','k'];
        for j = 1:length(T(1,:))
            line([T(2,j) T(2,j)], [0.75 1.25], 'HandleVisibility','off', 'Color', T_colors(T(1,j)));
        end
        hold off;
        
        savefig(ffig, strcat(pathname, '\', filename(12:24), '_behavior_phases.fig'));
    end

    function timeIt()
        % timer for 1s to update current time and frame display every
        % second
        myTimer = timer('ExecutionMode','fixedRate','Period',1,'TimerFcn',@updateCurrFrame);
        start(myTimer);
    end

    function updateCurrFrame(source, eventdata)
        % updates textfields which display current frame and time
        currFrame = controls.CurrentFrame;
        currFrameTxt.String = int2str(currFrame);
        currTimeTxt.String = num2time(currFrame);
        
        if abs(currFrame - lastFrame) > FPS*10 % only update slider position every 10s because video laggs during update
            slider.Value = currFrame;
            lastFrame = currFrame;
        end
    end

    function t = num2time(n)
        % gets frame number and calculates corresponding time in format
        % mm:ss:fff
        tmp1 = n/(FPS*60);
        min = floor(tmp1);
        if min < 10
            min_txt = ['0' num2str(min)];
        else
            min_txt = num2str(min);
        end
        tmp2 = tmp1 - min;
        tmp3 = tmp2 * 60;
        s = floor(tmp3);
        if s < 10
            s_txt = ['0' num2str(s)];
        else
            s_txt = num2str(s);
        end
        ms = round((tmp3 - s)*1000);
        t = [min_txt ':' s_txt ':' num2str(ms)];
    end

end




% TODO: create summary .txt
% 05:44:500 - 06:21:700: Sleep
% 05:55:600: Stimulus Presentation 1
% 06:12:300: Decision 1
% usw...