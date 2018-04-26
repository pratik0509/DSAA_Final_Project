# DSAA Project Spring'18

## Introduction to Problem Statement

Fitness tracking is gaining massive popularity due to the advent of wearable devices that cantrack your vital signs. Heart rate monitoring is one such feature in many devices such as smart-watches and wristbands. The heart rate is estimated in real time and can guide exercises to adjust their workload and training programs, which is especially useful in rehabilitation.
Most of the recording is done using **PhotoPlethysmoGraphic** (PPG) signals which are recorded from the wearer’s wrist. The PPG signal is recorded using **embedded pulse Oximeters**. A pulse oximeter records a signal by illuminating the skin with an LED and measuring the intensity changes as the light reflects off the exercises during the wearer’s skin, forming a PPG signal. Each cycle of the PPG signal corresponds to a cardiac cycle, thus the heart rate can be estimated from the periodicity of the PPG signal.

## Solution Approach

Took a completely signal processing approach.

 - Load the Data File from given and initialize the variables accordingly. Calculate
   the time window spaces and starting point of each window.

 - **De-noising**:

 	- First I tried without any noise reduction technique. For some cases where noise did not affect the PPG signal, got the Heart Rate almost equal to the ground truth value.

	- Second used **Leaky Integrator** on the output assuming that at start person is at rest so there will be less noise and Heart Rate cannot change abruptly. Still not so much improvement. Total squared error was still too high. Reason being Motion Artifacts was very high in the input PPG signal.

	- Next I tried using **LMS Adaptive Filter** to reduce noise from the whole signal. Used ```MATLAB dsp``` module. We are given accelerometer data as well as noisy signal which has some correlation with the accelerometer data. Since acceleration can be positive as well as negative but noise is only additive so used the squared acceleration data. This serves another purpose of reducing noise from signal, because when excessive movement is there MA introduced will be more than when less motion is present. Got better results but still not good enough.

	- Next I tried **Wiener Filter**. The Wiener filter is a filter used to produce an estimate of a desired or target random process by linear time-invariant (LTI) filtering of an observed noisy process. The result was almost similar to LMS Adaptive Filter. So I tried reducing noise again by using windows of 30s with step size of 2s. It gave better results than normal filtering.

	- Finally I tried using **RLS Filter** which gave even better results than Wiener Filter. Also used the concept of filtering in windows with some step size.

	- Finally to smoothen the irregular curve, used a **Leaky Integrator** with more preference given to the past value when the heart rate changes beyond a certain limit. Also window keeps on decreasing when encountered with multiple cases of high difference in consecutive values. This gave much better results.

  - **Heart Rate** calculation is done in *Frequency Domain*. **FFT** of 8s window cycle is taken and dominant frequency in 1.0 - 3.0 Hz is found out. That dominant frequency ```f``` is used in Heart Rate Calculation.
	```
	Heart Rate = f * 60
	```

### Scope For Improvement

Currently I have used only signal processing methods. **Machine Learning** techniques can be used too to determine the Heart Rate and noise reduction. Assumed that Heart Rate for initial value is  correct which might not be the case many times. Also window size could be **adaptively** changed using acceleration data and weights could be adjusted accordingly too.

## References

ICA-Based Improved DTCWT Technique for MA Reduction in PPG Signals With Restored
Respiratory Information (Raghuram, Madhav, etc.)

Motion Artifact Reduction in Photoplethysmographic Signals: A Review
(S. R. Yadhuraj , H. Harsha)

Review on heart-rate estimation from photoplethysmography and accelerometer
signals during physical exercise (Vijitha, etc.)

MathWorks(MATLAB) Website Documents

Wikipedia
