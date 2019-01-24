function plotResults(method,testType)

results_file = [method '_' testType '_results.mat'];
load(results_file);

total_correct = correct_azimuth & correct_elevation;

score = sum(total_correct(:));

fprintf(strcat('\t Total Score = [',num2str(score),'/',num2str(numel(correct_azimuth)),']\n'));

figure;
subplot(2,1,1);
plot(SNR,error_azimuth,'-x','lineWidth',2);
title('Azimuth MSE vs SNR');
subplot(2,1,2);
plot(SNR,error_elevation,'-x','lineWidth',2);
title('Elevation MSE vs SNR');

figure;
title('Accuracy vs SNR');
subplot(2,1,1);
plot(SNR,azimuth_acc,'-x','lineWidth',2);
title('Azimuth Accuracy vs SNR');
subplot(2,1,2);
plot(SNR,elevation_acc,'-x','lineWidth',2);
title('Elevation Accuracy vs SNR');

end

