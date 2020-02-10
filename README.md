# Human-like Planning

The objective of this project is learning high-level manipulation
planning skills from humans and transfer these skills to robot
planners. We used virtual reality to generate data from human
participants whilst they reached for objects on a cluttered table
top. From this, we devised a qualitative representation of the
task space to abstract human decisions, irrespective of the
number of objects in the way. Based on this representation,
human demonstrations were segmented and used to train
decision classifiers. Using these classifiers, our planner produced
a list of waypoints in the task space. These waypoints provide
a high-level plan, which can be transferred to any arbitrary
robot model. The VR dataset and the source code are released here. 
More information are given in the ICRA 2020 paper [1]. 


## Getting Started

These instructions will get you a copy of the project up and running on 
your local machine for development and testing purposes. 


### Prerequisites

MATLAB

### Install HLP 
Firstly you have to run

```
install_hlp 
```

### Dataset Demo

To go through the dataset and do some visualization, run: 

```
dataset_demo 
```
This script goes through some plotting functions that help you visualize 
the scene in of a VR trial showing the table and objects on top. 
You can also visualize motion of the human arm and objects. 
The animation video will be saved to '/animated-demonstrations' as 
'demo_Sxx_Tyyy' for subject 'xx' and trial 'yyy'.

## Loading dataset and segmenting the demonstrations
Before running experiments, training or testing, you have first to load 
the dataset and segment the human demonstrations. Run the following script:

```
load_segment_demonstrations
```
This script loads data from successful trials for all participants. It also segments the
demonstrations according to the qualitative spatio-temporal representation given in the paper.
Segmented demonstrations and extracted data are saved for further processing (e.g. classifiers training). 
Data is saved in '/Segmented-Dataset' directory as '/sub_xx/T_yyy.mat' for each 'xx' subject and 
'yyy' trial (demonstration).   


## Running experimets, training and testing
To reproduce the same experiments in ICRA-2020 paper with training and testing the decision classifiers, run:

```
HLP_experiment_protocols(first_time, training_required, training_protocol)
```

* Set 'first_time' flag to 1 for the first time you run this code. WHen set, the code will segment all human 
demonstrations, extract the required data for training and/or testing the classifiers and save extracted data to your 
local disk. When unset, the code will load the extracted data from your disk.
 
* Set 'training_required' flag to 1 only if you need to (re)train the decision classifiers. Unset it if you want to test 
the HLP algorithm using the trained decision classifiers.  

* Set 'training_protocol' to either '80_20' or 'num_subjects_effect'. '80_20' protocol performs cross validation on the 
whole data from all subjects with splitting the data into 80% for training and 20% for testing.  On the other hand, 
'num_subjects_effect' splits the data subject-wise. 

## License

This project is licensed under the MIT License - see the 
[LICENSE.md](LICENSE.md) file for details

## Have a question?
For queries about the HLP algorithm, please contact Mohamed Hasan (m.hasan@leeds.ac.uk).
For queries about the VR dataset, please contact Matthew Warburton (m.warburton@leeds.ac.uk).  
 
## Citing
If you used this code and/or dataset in academia, please cite the following work:  

[1] M. Hasan, M. Warburton, W. C. Agboh, M. R. Dogar, M. Leonetti, H. Wang, F. Mushtaq, M. Mon-Williams and A. G. Cohn, “Introducing a Human-like Planner for Reaching in Cluttered Environments, ” Accepted to ICRA 2020.


