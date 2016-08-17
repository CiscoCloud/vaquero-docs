# vaquero-docs
Documentation for the Vaquero project: [https://github.com/CiscoCloud/vaquero](https://github.com/CiscoCloud/vaquero)

Website: [ciscocloud.github.io/vaquero-docs](https://ciscocloud.github.io/vaquero-docs)


### How to modify the documentation
All docs and static assets like images are in the gh-pages branch, under `docs`.
The latest version of the docs are under `current`. If you make any changes to any of the docs
in `current`, please follow these steps to generate a new version tag so that the site stays updated:

First, make sure you have ruby installed in your computer.

1. Save all changes in .md and make sure all images are in the `current` directory.
2. `git add .`
3. Create a new tag: `git tag -a 1.01 -m "updated the architecture doc"`. Check the docs site to see what version tag makes the most sense.
4. Commit changes. This will run a script that uses a ruby markdown converter to get all the files into .html. It will also snapshot `current` into a folder matching your version tag, and push everything to the gh-pages branch. The website will update on its own.
