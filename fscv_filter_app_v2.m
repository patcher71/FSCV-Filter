function fscv_filter_app()
% FSCV_FILTER_APP - Interactive application for FSCV data filtering
% 
% Features:
% - Load color plot data
% - Set filter parameters
% - Interactive cursor on color plots
% - Compare original vs filtered traces
% - Save individual filtered I-T traces
% - Average multiple I-T traces

    % Create main figure
    fig = figure('Position', [50, 50, 1600, 900], ...
                 'Name', 'FSCV Filter Application', ...
                 'NumberTitle', 'off', ...
                 'MenuBar', 'none', ...
                 'ToolBar', 'figure');
    
    % Initialize app data structure
    app = struct();
    app.data_loaded = false;
    app.filtered = false;
    app.selected_voltage = 1;
    app.selected_time_idx = 1;
    app.root_directory = pwd;
    app.averaged_traces = [];  % Store individual traces for averaging
    app.average_trace = [];
    app.n_averaged = 0;
    app.min_trace_length = 0;
    
    % Create UI controls at top (Row 1)
    uicontrol('Style', 'pushbutton', 'String', 'Set Root Directory', ...
              'Position', [20, 850, 130, 30], ...
              'Callback', @(src, evt) setRootDirectoryCallback(fig));
    
    app.txt_directory = uicontrol('Style', 'text', 'String', pwd, ...
              'Position', [160, 850, 400, 25], ...
              'HorizontalAlignment', 'left', ...
              'BackgroundColor', [0.95 0.95 0.95]);
    
    uicontrol('Style', 'pushbutton', 'String', 'Load Color Plot File', ...
              'Position', [570, 850, 150, 30], ...
              'Callback', @(src, evt) loadDataCallback(fig));
    
    uicontrol('Style', 'text', 'String', 'Sampling Freq (Hz):', ...
              'Position', [740, 850, 120, 25], ...
              'HorizontalAlignment', 'right');
    app.txt_sampfreq = uicontrol('Style', 'edit', 'String', '10', ...
              'Position', [870, 850, 60, 25]);
    
    uicontrol('Style', 'text', 'String', 'Cutoff Freq (Hz):', ...
              'Position', [950, 850, 100, 25], ...
              'HorizontalAlignment', 'right');
    app.txt_cutoff = uicontrol('Style', 'edit', 'String', '0.05', ...
              'Position', [1060, 850, 60, 25]);
    
    uicontrol('Style', 'text', 'String', 'Filter Order:', ...
              'Position', [1140, 850, 80, 25], ...
              'HorizontalAlignment', 'right');
    app.txt_order = uicontrol('Style', 'edit', 'String', '2', ...
              'Position', [1230, 850, 40, 25]);
    
    uicontrol('Style', 'pushbutton', 'String', 'Apply Filter', ...
              'Position', [1290, 850, 100, 30], ...
              'Callback', @(src, evt) applyFilterCallback(fig));
    
    uicontrol('Style', 'pushbutton', 'String', 'Save Filtered I-T Plot', ...
              'Position', [1410, 850, 150, 30], ...
              'Callback', @(src, evt) saveTraceCallback(fig));
    
    % Averaging controls (Row 2)
    uicontrol('Style', 'pushbutton', 'String', 'Add to Average', ...
              'Position', [20, 810, 120, 30], ...
              'Callback', @(src, evt) addToAverageCallback(fig), ...
              'BackgroundColor', [0.8 1 0.8]);
    
    uicontrol('Style', 'pushbutton', 'String', 'Remove Last', ...
              'Position', [150, 810, 100, 30], ...
              'Callback', @(src, evt) removeLastCallback(fig));
    
    uicontrol('Style', 'pushbutton', 'String', 'Clear Average', ...
              'Position', [260, 810, 100, 30], ...
              'Callback', @(src, evt) clearAverageCallback(fig));
    
    app.txt_avg_count = uicontrol('Style', 'text', 'String', 'Traces averaged: 0', ...
              'Position', [370, 810, 150, 25], ...
              'HorizontalAlignment', 'left', ...
              'ForegroundColor', [0 0.6 0]);
    
    uicontrol('Style', 'pushbutton', 'String', 'Save Average I-T Plot', ...
              'Position', [530, 810, 150, 30], ...
              'Callback', @(src, evt) saveAverageCallback(fig), ...
              'BackgroundColor', [0.8 0.9 1]);
    
    app.txt_status = uicontrol('Style', 'text', 'String', 'Set root directory or load data to begin...', ...
              'Position', [20, 775, 600, 25], ...
              'HorizontalAlignment', 'left', ...
              'ForegroundColor', [0 0 0.8]);
    
    % Create axes for plots
    % Left column: Original data
    app.ax_original = axes('Position', [0.05, 0.4, 0.22, 0.35]);
    title('Original Data');
    
    % Middle column: Filtered data
    app.ax_filtered = axes('Position', [0.32, 0.4, 0.22, 0.35]);
    title('Filtered Data (Click to select)');
    
    % Right top: I vs T comparison
    app.ax_ivst = axes('Position', [0.60, 0.52, 0.36, 0.23]);
    title('Current vs Time');
    grid on;
    
    % Right middle: Average trace
    app.ax_average = axes('Position', [0.60, 0.27, 0.36, 0.18]);
    title('Averaged I-T Trace (n=0)');
    grid on;
    xlabel('Time (s)');
    ylabel('Current (nA)');
    
    % Right bottom: Voltammogram
    app.ax_voltammogram = axes('Position', [0.60, 0.02, 0.36, 0.18]);
    title('Voltammogram');
    grid on;
    xlabel('Data Point (Voltage)');
    ylabel('Current (nA)');
    
    % Store app data in figure
    fig.UserData = app;
    
    fprintf('\n=== FSCV Filter Application Started ===\n');
    fprintf('Root directory: %s\n', app.root_directory);
    fprintf('Click "Set Root Directory" to change working folder\n');
    fprintf('Click "Load Color Plot File" to begin\n\n');
end

function setRootDirectoryCallback(fig)
    app = fig.UserData;
    
    % Select directory
    selected_dir = uigetdir(app.root_directory, 'Select Root Directory for FSCV Data');
    
    if selected_dir == 0
        return;  % User canceled
    end
    
    app.root_directory = selected_dir;
    set(app.txt_directory, 'String', selected_dir);
    set(app.txt_status, 'String', sprintf('Root directory set to: %s', selected_dir));
    
    fprintf('Root directory set to: %s\n', selected_dir);
    
    fig.UserData = app;
end

function loadDataCallback(fig)
    app = fig.UserData;
    
    % Select file starting from root directory
    current_dir = pwd;
    cd(app.root_directory);  % Change to root directory for file dialog
    
    [file, path] = uigetfile({'*.txt;*.csv;*.tsv', 'Text Files (*.txt, *.csv, *.tsv)'; ...
                              '*.txt', 'Text Files (*.txt)'; ...
                              '*.csv', 'CSV Files (*.csv)'; ...
                              '*.*', 'All Files (*.*)'}, ...
                             'Select FSCV Color Plot Data');
    
    cd(current_dir);  % Return to original directory
    
    if isequal(file, 0)
        return;
    end
    
    % Update root directory to the selected file's directory
    app.root_directory = path;
    set(app.txt_directory, 'String', path);
    
    filename = fullfile(path, file);
    set(app.txt_status, 'String', 'Loading data...');
    drawnow;
    
    try
        % Load data
        try
            data = readmatrix(filename);
        catch
            data = dlmread(filename);
        end
        
        app.original_data = data;
        app.filename = file;
        app.n_voltages = size(data, 1);
        app.n_timepoints = size(data, 2);
        app.selected_voltage = round(app.n_voltages / 2);
        app.selected_time_idx = round(app.n_timepoints / 2);
        app.data_loaded = true;
        app.filtered = false;
        
        % Display original data
        axes(app.ax_original);
        cla;
        imagesc(app.original_data);
        colorbar;
        title('Original Data');
        xlabel('Time Point');
        ylabel('Data Point (Voltage)');
        colormap(jet);
        
        % Clear filtered view
        axes(app.ax_filtered);
        cla;
        title('Filtered Data (Apply filter first)');
        
        % Clear trace plots
        axes(app.ax_ivst);
        cla;
        grid on;
        title('Current vs Time');
        
        axes(app.ax_voltammogram);
        cla;
        grid on;
        title('Voltammogram');
        
        set(app.txt_status, 'String', sprintf('Loaded: %s (%d × %d)', file, app.n_voltages, app.n_timepoints));
        fprintf('Loaded: %s\n', filename);
        fprintf('Dimensions: %d voltage points × %d time points\n', app.n_voltages, app.n_timepoints);
        
    catch ME
        set(app.txt_status, 'String', 'Error loading file!');
        errordlg(['Error loading file: ' ME.message], 'Load Error');
        return;
    end
    
    fig.UserData = app;
end

function applyFilterCallback(fig)
    app = fig.UserData;
    
    if ~app.data_loaded
        warndlg('Please load data first', 'No Data');
        return;
    end
    
    % Get filter parameters
    sample_rate = str2double(get(app.txt_sampfreq, 'String'));
    cutoff_freq = str2double(get(app.txt_cutoff, 'String'));
    filter_order = str2double(get(app.txt_order, 'String'));
    
    % Validate
    if isnan(sample_rate) || sample_rate <= 0
        errordlg('Invalid sampling frequency', 'Parameter Error');
        return;
    end
    if isnan(cutoff_freq) || cutoff_freq <= 0 || cutoff_freq >= sample_rate/2
        errordlg('Invalid cutoff frequency (must be < Nyquist frequency)', 'Parameter Error');
        return;
    end
    if isnan(filter_order) || filter_order < 1
        errordlg('Invalid filter order', 'Parameter Error');
        return;
    end
    
    set(app.txt_status, 'String', 'Applying filter...');
    drawnow;
    
    % Apply filter
    try
        [app.filtered_data, app.background] = apply_filter_helper(app.original_data, ...
                                                                   sample_rate, cutoff_freq, filter_order);
        app.sample_rate = sample_rate;
        app.cutoff_freq = cutoff_freq;
        app.filter_order = filter_order;
        app.filtered = true;
        app.time = (0:app.n_timepoints-1) / sample_rate;
        
        % Display filtered data
        axes(app.ax_filtered);
        cla;
        app.h_img = imagesc(app.filtered_data);
        colorbar;
        title('Filtered Data (Click to select)');
        xlabel('Time Point');
        ylabel('Data Point (Voltage)');
        colormap(jet);
        hold on;
        
        % Add crosshairs
        app.h_vline = plot([app.selected_time_idx app.selected_time_idx], ...
                           [1 app.n_voltages], 'w--', 'LineWidth', 2);
        app.h_hline = plot([1 app.n_timepoints], ...
                           [app.selected_voltage app.selected_voltage], 'w--', 'LineWidth', 2);
        
        % Set up click callback
        set(app.h_img, 'ButtonDownFcn', @(src, evt) imageClickCallback(fig));
        
        % Update traces
        updateTraces(fig);
        
        set(app.txt_status, 'String', sprintf('Filter applied (fc=%.3f Hz)', cutoff_freq));
        fprintf('Filter applied successfully\n');
        
    catch ME
        set(app.txt_status, 'String', 'Error applying filter!');
        errordlg(['Error applying filter: ' ME.message], 'Filter Error');
        return;
    end
    
    fig.UserData = app;
end

function imageClickCallback(fig)
    app = fig.UserData;
    
    if ~app.filtered
        return;
    end
    
    % Get click coordinates
    click_point = get(gca, 'CurrentPoint');
    time_idx_click = round(click_point(1, 1));
    voltage_click = round(click_point(1, 2));
    
    % Validate
    if time_idx_click < 1
        time_idx_click = 1;
    elseif time_idx_click > app.n_timepoints
        time_idx_click = app.n_timepoints;
    end
    
    if voltage_click < 1
        voltage_click = 1;
    elseif voltage_click > app.n_voltages
        voltage_click = app.n_voltages;
    end
    
    % Update selection
    app.selected_voltage = voltage_click;
    app.selected_time_idx = time_idx_click;
    
    % Update crosshairs
    set(app.h_vline, 'XData', [time_idx_click time_idx_click]);
    set(app.h_hline, 'YData', [voltage_click voltage_click]);
    
    % Update stored data
    fig.UserData = app;
    
    % Update traces
    updateTraces(fig);
end

function updateTraces(fig)
    app = fig.UserData;
    
    if ~app.filtered
        return;
    end
    
    % Get current traces
    original_trace = app.original_data(app.selected_voltage, :);
    filtered_trace = app.filtered_data(app.selected_voltage, :);
    
    % Update I vs T plot (both original and filtered)
    axes(app.ax_ivst);
    cla;
    hold on;
    plot(app.time, original_trace, 'Color', [0.7 0.7 0.7], 'LineWidth', 1.5, 'DisplayName', 'Original');
    plot(app.time, filtered_trace, 'b', 'LineWidth', 1.5, 'DisplayName', 'Filtered');
    plot(app.time(app.selected_time_idx), filtered_trace(app.selected_time_idx), ...
         'ro', 'MarkerSize', 10, 'LineWidth', 2, 'DisplayName', 'Selected Point');
    grid on;
    xlabel('Time (s)');
    ylabel('Current (nA)');
    title(sprintf('Current vs Time (Voltage Point %d)', app.selected_voltage));
    legend('Location', 'best');
    hold off;
    
    % Update Voltammogram (filtered data at selected time)
    axes(app.ax_voltammogram);
    cla;
    hold on;
    plot(1:app.n_voltages, app.filtered_data(:, app.selected_time_idx), 'k', 'LineWidth', 1.5);
    plot(app.selected_voltage, app.filtered_data(app.selected_voltage, app.selected_time_idx), ...
         'ro', 'MarkerSize', 10, 'LineWidth', 2);
    grid on;
    xlabel('Data Point (Voltage)');
    ylabel('Current (nA)');
    title(sprintf('Voltammogram (Time = %.2f s)', app.time(app.selected_time_idx)));
    hold off;
    
    drawnow;
end

function addToAverageCallback(fig)
    app = fig.UserData;
    
    if ~app.filtered
        warndlg('Please apply filter first', 'No Filtered Data');
        return;
    end
    
    % Get current filtered trace
    current_trace = app.filtered_data(app.selected_voltage, :);
    
    % Add to collection
    if isempty(app.averaged_traces)
        app.averaged_traces = current_trace;
        app.min_trace_length = length(current_trace);
    else
        % Check if trace length matches
        if length(current_trace) ~= size(app.averaged_traces, 2)
            % Trim to minimum length
            min_len = min(length(current_trace), size(app.averaged_traces, 2));
            current_trace = current_trace(1:min_len);
            app.averaged_traces = app.averaged_traces(:, 1:min_len);
            app.min_trace_length = min_len;
            
            fprintf('Warning: Trace length mismatch. Trimmed to %d points.\n', min_len);
            set(app.txt_status, 'String', sprintf('Warning: Trimmed traces to %d points', min_len));
        end
        app.averaged_traces = [app.averaged_traces; current_trace];
    end
    
    % Calculate new average
    app.average_trace = mean(app.averaged_traces, 1);
    app.n_averaged = size(app.averaged_traces, 1);
    
    % Update display
    set(app.txt_avg_count, 'String', sprintf('Traces averaged: %d', app.n_averaged));
    
    % Plot average (use trimmed time vector if needed)
    axes(app.ax_average);
    cla;
    time_vector = app.time(1:length(app.average_trace));
    plot(time_vector, app.average_trace, 'r', 'LineWidth', 2);
    grid on;
    xlabel('Time (s)');
    ylabel('Current (nA)');
    title(sprintf('Averaged I-T Trace (n=%d)', app.n_averaged));
    
    set(app.txt_status, 'String', sprintf('Added trace from voltage point %d (total: %d)', ...
                                          app.selected_voltage, app.n_averaged));
    fprintf('Added trace %d to average (voltage point %d)\n', app.n_averaged, app.selected_voltage);
    
    fig.UserData = app;
end

function removeLastCallback(fig)
    app = fig.UserData;
    
    if app.n_averaged == 0
        warndlg('No traces to remove', 'Empty Average');
        return;
    end
    
    % Remove last trace
    app.averaged_traces(end, :) = [];
    app.n_averaged = app.n_averaged - 1;
    
    % Recalculate average
    if app.n_averaged > 0
        app.average_trace = mean(app.averaged_traces, 1);
    else
        app.average_trace = [];
        app.averaged_traces = [];
    end
    
    % Update display
    set(app.txt_avg_count, 'String', sprintf('Traces averaged: %d', app.n_averaged));
    
    % Update plot
    axes(app.ax_average);
    cla;
    if app.n_averaged > 0
        time_vector = app.time(1:length(app.average_trace));
        plot(time_vector, app.average_trace, 'r', 'LineWidth', 2);
    end
    grid on;
    xlabel('Time (s)');
    ylabel('Current (nA)');
    title(sprintf('Averaged I-T Trace (n=%d)', app.n_averaged));
    
    set(app.txt_status, 'String', sprintf('Removed last trace (remaining: %d)', app.n_averaged));
    fprintf('Removed last trace from average (remaining: %d)\n', app.n_averaged);
    
    fig.UserData = app;
end

function clearAverageCallback(fig)
    app = fig.UserData;
    
    if app.n_averaged == 0
        return;
    end
    
    % Confirm clear
    answer = questdlg(sprintf('Clear all %d averaged traces?', app.n_averaged), ...
                      'Clear Average', 'Yes', 'No', 'No');
    
    if strcmp(answer, 'Yes')
        app.averaged_traces = [];
        app.average_trace = [];
        app.n_averaged = 0;
        
        % Update display
        set(app.txt_avg_count, 'String', 'Traces averaged: 0');
        
        % Clear plot
        axes(app.ax_average);
        cla;
        grid on;
        xlabel('Time (s)');
        ylabel('Current (nA)');
        title('Averaged I-T Trace (n=0)');
        
        set(app.txt_status, 'String', 'Average cleared');
        fprintf('Average cleared\n');
        
        fig.UserData = app;
    end
end

function saveAverageCallback(fig)
    app = fig.UserData;
    
    if app.n_averaged == 0
        warndlg('No averaged data to save', 'No Average');
        return;
    end
    
    % Ask user for save location
    current_dir = pwd;
    cd(app.root_directory);
    
    % Create default name
    [~, source_name, ~] = fileparts(app.filename);
    default_name = sprintf('%s_averaged_n%d.txt', source_name, app.n_averaged);
    
    [file, path] = uiputfile({'*.txt', 'Text Files (*.txt)'; ...
                              '*.csv', 'CSV Files (*.csv)'}, ...
                             'Save Averaged I-T Trace', default_name);
    
    cd(current_dir);
    
    if isequal(file, 0)
        return;
    end
    
    output_filename = fullfile(path, file);
    
    try
        % Prepare data: [time, average_current]
        time_vector = app.time(1:length(app.average_trace));
        output_data = [time_vector', app.average_trace'];
        
        % Save with header
        fid = fopen(output_filename, 'w');
        fprintf(fid, '%% Averaged I-T trace from %s\n', app.filename);
        fprintf(fid, '%% Number of traces averaged: %d\n', app.n_averaged);
        fprintf(fid, '%% Sampling Rate: %.2f Hz\n', app.sample_rate);
        fprintf(fid, '%% Cutoff Frequency: %.3f Hz\n', app.cutoff_freq);
        fprintf(fid, '%% Filter Order: %d\n', app.filter_order);
        fprintf(fid, '%% Time(s)\tCurrent(nA)\n');
        fclose(fid);
        
        % Append data
        writematrix(output_data, output_filename, 'Delimiter', '\t', 'WriteMode', 'append');
        
        set(app.txt_status, 'String', sprintf('Saved average (n=%d): %s', app.n_averaged, file));
        fprintf('Saved averaged trace to: %s\n', output_filename);
        
    catch ME
        errordlg(['Error saving file: ' ME.message], 'Save Error');
    end
end

function saveTraceCallback(fig)
    app = fig.UserData;
    
    if ~app.filtered
        warndlg('Please apply filter first', 'No Filtered Data');
        return;
    end
    
    % Ask user for save location (starting from root directory)
    current_dir = pwd;
    cd(app.root_directory);
    
    % Create default name from source file
    [~, source_name, ~] = fileparts(app.filename);
    default_name = sprintf('%s_filtered_v%d.txt', source_name, app.selected_voltage);
    
    [file, path] = uiputfile({'*.txt', 'Text Files (*.txt)'; ...
                              '*.csv', 'CSV Files (*.csv)'}, ...
                             'Save Filtered I-T Trace', default_name);
    
    cd(current_dir);
    
    if isequal(file, 0)
        return;
    end
    
    output_filename = fullfile(path, file);
    
    try
        % Prepare data: [time, current]
        filtered_trace = app.filtered_data(app.selected_voltage, :)';
        output_data = [app.time', filtered_trace];
        
        % Save with header
        fid = fopen(output_filename, 'w');
        fprintf(fid, '%% Filtered I-T trace from %s\n', app.filename);
        fprintf(fid, '%% Voltage Point: %d\n', app.selected_voltage);
        fprintf(fid, '%% Sampling Rate: %.2f Hz\n', app.sample_rate);
        fprintf(fid, '%% Cutoff Frequency: %.3f Hz\n', app.cutoff_freq);
        fprintf(fid, '%% Filter Order: %d\n', app.filter_order);
        fprintf(fid, '%% Time(s)\tCurrent(nA)\n');
        fclose(fid);
        
        % Append data
        writematrix(output_data, output_filename, 'Delimiter', '\t', 'WriteMode', 'append');
        
        set(app.txt_status, 'String', sprintf('Saved: %s', file));
        fprintf('Saved filtered trace to: %s\n', output_filename);
        
    catch ME
        errordlg(['Error saving file: ' ME.message], 'Save Error');
    end
end

function [filtered_data, background] = apply_filter_helper(data, sample_rate, cutoff_freq, filter_order)
    % Apply zero-phase high-pass filter
    [n_voltages, n_timepoints] = size(data);
    nyquist_freq = sample_rate / 2;
    normalized_cutoff = cutoff_freq / nyquist_freq;
    [b, a] = butter(filter_order, normalized_cutoff, 'high');
    
    filtered_data = zeros(size(data));
    for i = 1:n_voltages
        filtered_data(i, :) = filtfilt(b, a, data(i, :));
    end
    
    background = data - filtered_data;
end