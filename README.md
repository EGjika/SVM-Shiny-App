# SVM-Shiny-App
This shiny app may help you understand the importance of the parameters when using SVM. 

![image](https://github.com/user-attachments/assets/8c478120-18c7-4891-9cb7-2537e50097a4)

ksvm:  A function from the kernlab package to fit an SVM model. It supports a variety of kernel functions and classification types.
Inputs to ksvm:
x and y:
x: A matrix or data frame of predictor variables (features).
y: A factor vector of target (response) labels.
type = "C-svc":
Specifies the type of SVM model. "C-svc" refers to the C-support vector classification, a standard classification SVM where the user specifies a penalty parameter 
𝐶
C.
kernel = kernel_function:

Determines the kernel function used in the SVM.
A kernel maps the input data into a higher-dimensional space to make it linearly separable.
kernel_function is likely a user input in the app, where users can choose between kernels like:
"linear": Linear decision boundary.
"rbfdot": Radial Basis Function (Gaussian) kernel.
"polydot": Polynomial kernel.
C = input$C:

The 
𝐶
C-parameter is a user-defined penalty parameter.

Predictor Variables (x):

The x variable can be one or more numeric variables (features) used as input to the model.
It can be a single column (one feature) or multiple columns (multivariate input).
Response Variable (y):

The response (y) must be categorical (factor), as the SVM type specified is "C-svc", which is for classification problems.

Single Numeric Variable and a Class:

If x contains only one numeric variable, SVM will still work, but it is essentially a one-dimensional decision boundary, which might limit its use.
For example:
Predict whether a flower is setosa, versicolor, or virginica based only on Sepal.Length.
Multiple Numeric Variables and a Class:

This is the more common case where SVM excels.
Multiple numeric features allow the model to separate classes in a higher-dimensional space.
