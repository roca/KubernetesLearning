import numpy as np

def handle(event, context):
    a = np.array([1,2,3,4])
    b = np.array([1,2,3,4])

    return {
        "statusCode": 200,
        "body": a.dot(b)
    }
