# MATLAB Changepoint Detection Algorithms
This includes all files used for changepoint detection with the `findchangepts` function built into MATLAB. Just download everything and add to path. You'll need to download the LiDAR images as well.

Feel free to reach out to me with any questions, concerns, or updates! I'd love to hear more about the progress of this project :)

My email is carolinx@umich.edu

## Which algorithm is which?
There are two algorithms, one for the insects from the 2020 Hyalite dataset, and one for the bees from the 2022 bee dataset. Everything that pertains to the Hyalite dataset has 'insect' in its, everything for the bees have 'bee' in its name.

## Making the confusion matrices
`insectConfusionStruct.m` and `beeConfusionStruct.m` are the two scripts that store whether or not there is an insect in the image, and whether or not the algorithm found an insect. These scripts use `insectImgs.txt` and `beeImgs.txt`, which are text files that list all of the images that contain an insect.

Once the `___ConfusionStruct` scripts are done running, the resulting struct, `s`, is saved to a `.mat` file. Make sure to rename it in the script! To see the confusion matrix, use the function `plotconfusion(s.y,s.yHat)` in the command window.

## Results
`fnInsect.txt`, `fpInsect.txt`, and `pInsect.txt` list all of the false negatives, false positives, and identified insects respectively in the Hyalite dataset.
