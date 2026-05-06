import itertools

id_generator = itertools.count(start=0, step=1)

def get_id():
    return next(id_generator)