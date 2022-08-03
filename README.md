# MATLAB Changepoint Detection Algorithms
This includes all files used for changepoint detection with the `findchangepts` function built into MATLAB. Just download everything and add to path. You'll need to download the LiDAR images as well.

Here is the link to my report and my personal documentation over the 10 week period: https://www.overleaf.com/read/qktsqmkzvkqx

Feel free to reach out to me with any questions, concerns, or updates! I'd love to hear more about the progress of this project :)

My email is carolinx@umich.edu

## Which algorithm is which?
There are two algorithms, one for the insects from the 2020 Hyalite dataset, and one for the bees from the 2022 bee dataset. Everything that pertains to the Hyalite dataset has 'insect' in its name, everything for the bees have 'bee' in its name.

## Making the confusion matrices
`insectConfusionStruct.m` and `beeConfusionStruct.m` are the two scripts that store whether or not there is an insect in the image, and whether or not the algorithm found an insect. These scripts use `insectImgs.txt` and `beeImgs.txt`, which are text files that list all of the images that contain an insect.

Once the `___ConfusionStruct` scripts are done running, the resulting struct, `s`, is saved to a `.mat` file. Make sure to rename it in the script! To see the confusion matrix, use the function `plotconfusion(s.y,s.yHat)` in the command window.

## Results
`insectStruct.mat` is the final struct for the Hyalite dataset. `beeStruct.mat` is the struct for the bee dataset using the bee algorithm and `beeStruct4.mat` is the struct for the bee dataset using the insect algorithm.

To see the confusion matrices for these structs, load in the mat file and then use the function: `plotconfusion(s.y,s.yHat)`

To see which images were false positives, false negatives, and correctly identified, use the script `misclassOutput.m`. You just need to have the struct loaded in the workspace. Make sure to change the output file names and then run.

`fnInsect.txt`, `fpInsect.txt`, and `pInsect.txt` list all of the false negatives, false positives, and identified insects respectively in the Hyalite dataset. Same thing for the bee dataset. `fnBee.txt`, `fpBee.txt`, and `pBee.txt` are from the bee algorithm on the bee dataset. `fnBeeInsect.txt`, `fpBeeInsect.txt`, and `pBeeInsect.txt` are from the insect algorithm on the bee dataset.

## Testing
`insectAlgorithm.m` and `beesAlgorithm.m` are the functions that actually detect the insects. `insectChangepoint.m` and `beesChangepoint.m` are script versions of those functions. To run the changepoint scripts, manually load in the data, choose which image you want to look at, and then run the script. These scripts are useful for breakpoints.

## Stuff
The other things I have tried are all in the stuff folder. I talk about some of it in my documentation. If you have any questions about anything in this folder just email me.

<br />
<sup><sub>Written by Caroline Xu, NSF Research Experience for Undergraduates (REU) at Montana State University, 2022</sub></sup>
