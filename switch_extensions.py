import os
import sys

def switch_extensions(efrom,eto):
    ignore = ['.git']

    contents = os.listdir('.')

    for obj in contents:
        if obj in ignore:
            continue
        elif os.path.isfile(obj):
            switch(obj,efrom,eto)
        elif os.path.isdir(obj):
            os.chdir(obj)
            switch_extensions(efrom,eto)
            os.chdir('..')

def switch(f,efrom,eto):
    try:
        name, ext = f.split('.')
    except:
        return

    if ext == efrom:
        os.rename(f, name + '.' + eto)

if __name__ == '__main__':
    switch_extensions(sys.argv[1], sys.argv[2])