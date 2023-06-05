
% Copy this template configuration file to your VOT workspace.

JMMAC_path = ''; %% Enter the full path to the JMMAC repository root folder.

tracker_label = 'JMMAC_CPU';
tracker_command = generate_matlab_command('benchmark_tracker_wrapper(''JMMAC_CPU'', ''run_JMMAC_CPU'', true)', {[JMMAC_path '/VOT_integration/benchmark_wrapper']});
tracker_interpreter = 'matlab';