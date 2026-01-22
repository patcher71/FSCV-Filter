# FSCV-Filter
Simple Zero Phase Filter for FSCV Color Plots

This application was written with the assistance of Claude AI.

When dealing with color plots in FSCV experiments, a slow drift is often visible, especially at later time points in the file.  This slow drift component can be reduced or eliminated using a simple, 'zero-phase' high pass filter without altering the primary fast dopamine signal.  This processing approach was reported by DeWaele et al. (see here:https://pmc.ncbi.nlm.nih.gov/articles/PMC5705064/). This application implements this simple zero pass filter in Matlab. 

# Step 1-Create Color Plot TXT file

Using the HDCV Analysis program, export the color plot to a text file.

# Step 2-Open the Color Plot in the application

Upon loading the plot, you will see the color plot on the left.  



<img width="1986" height="1182" alt="image" src="https://github.com/user-attachments/assets/389538c6-e33e-4934-8b7a-e311593b3949" />

# Step 3-Adjust Settings

After adjusting the settings, hit 'Apply Filter' and you will see the filtered color plot on the right.

<img width="1102" height="977" alt="image" src="https://github.com/user-attachments/assets/ae679664-1be9-42a4-90bb-cd617d5cbf7d" />

# Step 4--Click on the color plot to find the peak DA current 

You will now see the original current, as well as the filtered current overlaid on the I vs T plot.  The voltammagram is shown on the lower right. Notice the prominent slow 'tail' that follows the dopamine current has been largely removed. This will facilitate analysis of the primary signal. If you are happy with the filtered signal, you can save this I vs T text file and proceed.  Otherwise, you can adjust the filter settings---just be sure to pick values that don't disrupt the peak or kinetics of the primary signal!

<img width="1988" height="1177" alt="image" src="https://github.com/user-attachments/assets/a00b631c-c524-45ea-a137-cd345a645378" />


## **NEW: Version 2 provides for signal averaging of I-T plots**

In version 2, you can add individual I-T plots to a running average that can then be saved for later analysis/plotting. Simply run as above, then add the I-T to the average using the green button, load the next file, etc.  Once you have an averaged response that looks reasonable (typically 3-4 files), you can save it.  

<img width="1997" height="1182" alt="image" src="https://github.com/user-attachments/assets/5660af0b-c633-4ed1-bbf2-9fe5001a7e22" />
