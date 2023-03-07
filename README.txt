
Biomedical Signal Processing 22/23 Project Developed By:
Renato Avellar Nobre - 984405

To execute this code, open this folder on Matlab ad the Project folder. In the Matlab file inspector menu add all the data, plots and utils folder to path. 

To run the experiment, execute the main.m file. You might need to install some Matlab add-on in case of an error.

The solution pipeline is the file pipeline in the utils folder. The main file calls the pipeline for multiple experimentation.

The single_experiment variable in the main file controls whether to run on one datafile or to run on the whole data set. If the option is to run on one file, the project will also plot the results. Plotting on the whole data set is not recommended. 

If you wish to add your own file, do the following steps:
1. Certify that the file is a csv with 6 columns denominated: AcellX AcellY AcellZ GyroX GyroY GyroZ
2. Change the file name to SUBJECTNAME00RR-00-00BPM.csv where the 00 corresponds to, in order, respiratory rate, minimum heart rate and maximum heart rate. If there is one measured heart rate, set minimum and maximum to it.
3. Move the file to the data folder.
4. On main: set data_file to the file name
5. On main: set Fs to the sampling frequency
