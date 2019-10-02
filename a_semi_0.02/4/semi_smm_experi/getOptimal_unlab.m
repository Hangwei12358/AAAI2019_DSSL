% the function of extract optimal results into one file
% by Hangwei, Aug.21.2017
FolderPath = '/home/hangwei/Documents/SemiSMM_Hangwei/wisdm_transformed_large_ratio_final/wisdm_transformed_labeled_ratio/labeled_0.02/';
targetFilePath = strcat(FolderPath, 'Results_All_Semi.txt');
% event results
fID_event = fopen('micro_macro_event_unlab.txt','r');
fgets(fID_event);
event_content = textscan(fID_event, '%*s %s %*s %s');
targetRow = size(event_content{1,1}, 1);
event_optimal1 = event_content{1,1}{targetRow, 1};
event_optimal2 = event_content{1,2}{targetRow, 1};
event_optimal1 = str2double(event_optimal1);
event_optimal2 = str2double(event_optimal2);
% frame results
fID_frame = fopen('micro_macro_frame_unlab.txt','r');
fgets(fID_frame);
frame_content = textscan(fID_frame, '%*s %s %*s %s');
targetRow = size(frame_content{1,1}, 1);
frame_optimal1 = frame_content{1,1}{targetRow, 1};
frame_optimal2 = frame_content{1,2}{targetRow, 1};
frame_optimal1 = str2double(frame_optimal1);
frame_optimal2 = str2double(frame_optimal2);
% save results into txt file, append to the file
saveFile = fopen(targetFilePath, 'a');
fprintf(saveFile,'%.4f %.4f %.4f %.4f\n', event_optimal1, event_optimal2, frame_optimal1, frame_optimal2);
fclose(fID_event);
fclose(saveFile);