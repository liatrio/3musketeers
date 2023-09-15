1. Copy the `3m8s/Makefile` and `3m8s/compose.yaml` into your project dir
2. Copy all files for desired plugin from this `3m8s.d` into a `3m8s.d` dir inside your project dir
    e.g.
    ```shell
    cp Makefile compose.yaml <my-project-dir>/
    cp 3m8s.d/k9s.* <my-project-dir>/3m8s.d/
    ```

Run!

Recommend setting the following alias:
# TODO put this in a .alias file for easy sourcing?
``alias make="make --"``