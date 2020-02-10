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

This script loads data from successful trials for all participants. 
Afterwards, it segments the demonstrations according to the qualitative 
spatio-temporal representation given in the paper. The segmented 
demonstrations and extracted data are saved for further processing 
(e.g. classifiers training). Data is saved in '/Segmented-Dataset' 
directory as '/sub_xx/T_yyy.mat' for each 'xx' subject and 'yyy' trial 
(demonstration).   


## Running experimets, training and testing
To reproduce the same experiments in ICRA-2020 paper with 
training and testing the HLP algorithm, run:

```
HLP_experiment_protocols(first_time, training_required, training_protocol, plot_plan)
```

* Set 'first_time' flag to 1 for the first time you run this code. When 
set, the code will first load the segmented demonstrations that were saved in 
the previous step. Afterwards, it will extract the data required for 
training the classifiers/regression models. Data are extracted as 
state-action pairs (training examples) for different classification and 
regression models. Data extracted from the whole dataset are saved as 
'/segmented-demonstrations/all_training_examples.mat'. This flag 
must be set at the first run only. At other runs, the code will just load 
the extracted data.

* Set 'training_required' flag to 1 only if you need to (re)train the 
decision classifiers. The trained models are saved at '\trained-models'
Unset it if you want to test the HLP algorithm using the (already) 
trained decision classifiers and regression models.  

* Set 'training_protocol' to either '80_20' or 'num_subjects_effect'. 
'80_20' protocol performs cross validation on the whole dataset from all 
subjects with splitting the data into 80% for training and 20% for testing.  On the other hand, 
'num_subjects_effect' splits the data on a subject-wise basis. 

* In case of testing the HLP algorithm, set 'plan_plot' to 1 if you want 
to visualize the generated high-level plan.

For example, at the first time run the following:
```
HLP_experiment_protocols(1, 1, '80_20', 0)
```
to (1) load and segment the datset (2) extract the 
data required for machine learning and save the training examples and (3) 
use the training examples to train the HLP algorithm 
classifiers and regressors.   

After the first time run:
```
HLP_experiment_protocols(0, 0, '80_20', 1)
```  
to test the HLP algorithm on new scenes unseen during training and visualize 
the high-level generated plan.



## Have a question?
For queries about the HLP algorithm, please contact Mohamed Hasan (m.hasan@leeds.ac.uk).
For queries about the VR dataset, please contact Matthew Warburton (m.warburton@leeds.ac.uk).  

 
## Citation
If you find our code/dataset useful in your research, please cite our work:
[1] M. Hasan, M. Warburton, W. C. Agboh, M. R. Dogar, M. Leonetti, H. Wang,
 F. Mushtaq, M. Mon-Williams and A. G. Cohn, “Introducing a Human-like 
 Planner for Reaching in Cluttered Environments, ” Accepted to appear in 
 ICRA 2020.


## License
This project is licensed under the MIT License - see the 
[LICENSE.md](LICENSE.md) file for details.
