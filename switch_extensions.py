import os
import sys

def switch_extensions(efrom,eto):
    contents = os.listdir('.')

    for f in contents:
        switch(f,efrom,eto)

def switch(f,efrom,eto):
    try:
        name, ext = f.split('.')
    except:
        return
        
    if ext == efrom:
        os.rename(f, name + '.' + eto)

if __name__ == '__main__':
    switch_extensions(sys.argv[1], sys.argv[2])