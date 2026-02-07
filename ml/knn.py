import numpy as np
from scipy import stats

class KNeighborsClassifier:
    """
    K-Nearest Neighbors Classifier
    This class implements the k-nearest neighbors algorithm for classification.
    """
    def __init__(self, n_neighbors=5,distance_metric="l2"):
        #Initializes the KNeighborsClassifier with the specified number of neighbors. Defaults to 1.
        #Default distance_metric is L2 norm

        self.n_neighbors = n_neighbors
        self.distance_metric = distance_metric
        self.X_train = None
        self.y_train = None

    def fit(self, X_train,Y_train):
        #This method fits the k-nearest neighbors classifier from the training data. X_train is the training data, represented as a numpy array of shape (n_samples, n_features), and Y_train is the target values of the training data, represented as a numpy array of shape (n_samples,)
        self.X_train = np.array(X_train)
        self.Y_train = np.array(Y_train)

    def predict(self, X_test):
        #This method predicts the class labels for a set of data samples. X_test is the data to be predicted, represented as a numpy array of shape (n_samples, n_features)

        if self.distance_metric == "l2":
            # Euclidean distance squared (sqrt is omitted for speed as ranking remains same)
            dist_matrix = np.sum((X_test[:, np.newaxis, :] - self.X_train)**2, axis=2)
        else:
            # Manhattan distance
            dist_matrix = np.sum(np.abs(X_test[:, np.newaxis, :] - self.X_train), axis=2)

        nearest_indices = np.argpartition(dist_matrix, self.n_neighbors, axis=1)[:, :self.n_neighbors]

        nearest_labels = self.Y_train[nearest_indices]

        predictions = np.apply_along_axis(
            lambda x: np.bincount(x).argmax(), 
            axis=1, 
            arr=nearest_labels
        )

        return predictions
