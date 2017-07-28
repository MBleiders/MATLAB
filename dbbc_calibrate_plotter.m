[fileID,message] = fopen('Z:\Manuals\Calibration\dbbc\phase_cal\BOARD_ALL-2017-030T094751-calib.txt', 'r')

cal_file= textscan(fileID,'%d %d %d %d %d', 256);
fclose(fileID);

cal_file{4};
semilogy(cal_file{2})
hold on
semilogy(cal_file{3})
hold on
semilogy(cal_file{4})
hold on
semilogy(cal_file{5})
hold off
legend('IFA','IFB','IFC','IFD','Location','northeast');
grid on 
grid minor