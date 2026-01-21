# FAMTDE
​​ Please run the program on the PlatEMO platform.
If you use this program, please cite the following paper:
"W. Wu et al., "Frequency-domain Assisted Multitask Differential Evolution Algorithm for Operational Optimization of Coal Mine Integrated Energy Systems," in IEEE Transactions on Evolutionary Computation, doi: 10.1109/TEVC.2026.3656445."


1. PlatEMO platform can be downloaded from this website: [Link](https://github.com/BIMK/PlatEMO).

2. After extracting the files, place the FAMTDE folder into the directory ./PlatEMO/Algorithms/Multi-objective optimization, place the AidenProblem folder into the directory ./PlatEMO/Problems/Multi-objective optimization, and place the chebfun folder into the directory ./PlatEMO. Then, add the chebfun file path in MATLAB.

3. Subsequently, you can run the program by selecting the corresponding problem and algorithm according to the PlatEMO manual, for example: platemo('algorithm',@FAMTDE,'problem',@Aiden_f22_problem1_1,'maxFE',300000);
