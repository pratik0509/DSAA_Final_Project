**CLEANING**: Cleaned the data set using High-Pass filter after using
FFT.

Kalman Filter and Smoother


From PPG signal we can calculate BPM using:

 - Peaks counting: Detect peaks in the data. Calculate distance between 1 adjacent peaks.

	```BPM=(Sampling Rate/(peak(i+1)-peak(i)))*60;```
 - Do the FFT transform for a set of data. Then find the peak from 0.5-2.5Hz. Finally multiply that peak's frequency with 60s.



 Additional thing which we can do is:

  - Pad with large number of zeros to increase the resolution though incurring power
  	leakage and then find more accurate BPM from PPG.


```16x dilation with zeros```
